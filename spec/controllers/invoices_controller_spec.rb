require "rails_helper"

RSpec.describe InvoicesController, type: :controller do
  let(:customer) { create(:customer) }

  describe "authentication" do
    it "redirects unauthenticated requests to the login page" do
      get :index
      expect(response).to redirect_to(new_session_path)

      get :new
      expect(response).to redirect_to(new_session_path)

      get :show, params: { uuid: "abc" }
      expect(response).to redirect_to(new_session_path)

      post :create, params: { invoice: { items_attributes: {} } }
      expect(response).to redirect_to(new_session_path)
    end
  end

  describe "GET #index" do
    before { session[:customer_id] = customer.id }

    it "lists only the current customer's invoices" do
      mine = create_list(:invoice, 2, customer: customer)
      create_list(:invoice, 2, customer: create(:customer))

      get :index

      expect(assigns(:invoices)).to match_array(mine)
    end
  end

  describe "GET #new" do
    before { session[:customer_id] = customer.id }

    it "builds an invoice for the current customer with two default items" do
      get :new

      invoice = assigns(:invoice)
      expect(invoice.customer_id).to eq(customer.id)
      expect(invoice.items.size).to eq(2)
      expect(invoice.items.map(&:quantity)).to eq([1, 0])
      expect(response).to render_template(:new)
    end
  end

  describe "POST #create" do
    before { session[:customer_id] = customer.id }

    let(:valid_params) do
      {
        invoice: {
          items_attributes: {
            "0" => { description: "Laptop", quantity: "1", unit_price: "1000" },
            "1" => { description: "Warranty", quantity: "0", unit_price: "50" }
          }
        }
      }
    end

    it "creates the invoice for the current customer" do
      expect { post :create, params: valid_params }.to change(Invoice, :count).by(1)

      invoice = Invoice.last
      expect(invoice.customer).to eq(customer)
      expect(response).to redirect_to(invoice_path(invoice))
    end

    it "persists only the items with a positive quantity" do
      post :create, params: valid_params

      invoice = Invoice.last
      expect(invoice.items.size).to eq(1)
      expect(invoice.items.map(&:description)).to eq(["Laptop"])
    end

    it "re-renders the form with two rows when validation fails" do
      invalid_params = {
        invoice: {
          items_attributes: {
            "0" => { description: "", quantity: "1", unit_price: "1000" }
          }
        }
      }

      expect { post :create, params: invalid_params }.not_to change(Invoice, :count)

      expect(response).to render_template(:new)
      expect(response.status).to eq(422)
      expect(assigns(:invoice).items.size).to eq(2)
    end

    it "re-renders with default rows when no items are submitted" do
      expect { post :create, params: { invoice: {} } }.not_to change(Invoice, :count)

      expect(response).to render_template(:new)
      expect(response.status).to eq(422)
      expect(assigns(:invoice).items.map(&:quantity)).to eq([1, 0])
    end

    it "gracefully re-renders the form when the invoice param is missing instead of crashing" do
      expect { post :create, params: {} }.not_to raise_error

      expect(response).to render_template(:new)
      expect(response.status).to eq(422)
      expect(assigns(:invoice).items.map(&:quantity)).to eq([1, 0])
    end

    it "rejects a blank description" do
      params_without_description = {
        invoice: {
          items_attributes: {
            "0" => { description: "", quantity: "1", unit_price: "1000" }
          }
        }
      }

      post :create, params: params_without_description

      expect(assigns(:invoice).items.first.errors[:description]).to include("can't be blank")
    end

    it "redirects to the existing invoice when the uuid collides" do
      existing = create(:invoice, customer: customer, uuid: "collision-key")
      allow(SecureRandom).to receive(:uuid).and_return(existing.uuid)

      post :create, params: valid_params

      expect(response).to redirect_to(invoice_path(existing))
    end
  end

  describe "GET #show" do
    before { session[:customer_id] = customer.id }

    it "finds the invoice by uuid and reads its persisted totals" do
      invoice = build(:invoice, customer: customer, uuid: "abc-123")
      invoice.items.build(description: "Laptop", quantity: 1, unit_price: 1000)
      invoice.save!(validate: false)

      get :show, params: { uuid: invoice.uuid }

      expect(assigns(:invoice)).to eq(invoice)
      expect(assigns(:invoice).subtotal).to eq(BigDecimal("1000"))
      expect(assigns(:invoice).tax).to eq(BigDecimal("160"))
      expect(assigns(:invoice).total).to eq(BigDecimal("1160"))
      expect(assigns(:additional_taxes)).to be false
      expect(response).to render_template(:show)
    end

    it "returns 404 for an unknown uuid" do
      expect { get :show, params: { uuid: "nope" } }
        .to raise_error(ActiveRecord::RecordNotFound)
    end

    it "returns 404 for a blank uuid" do
      expect { get :show, params: { uuid: "" } }
        .to raise_error(ActiveRecord::RecordNotFound)
    end

    it "returns 404 for another customer's invoice" do
      other = create(:invoice, customer: create(:customer), uuid: "someone-elses")

      expect { get :show, params: { uuid: other.uuid } }
        .to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
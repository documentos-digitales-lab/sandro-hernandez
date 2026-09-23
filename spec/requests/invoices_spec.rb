require "rails_helper"

RSpec.describe "Invoices", type: :request do
  let(:customer) { create(:customer) }
  let!(:other_customer) { create(:customer) }

  before { post "/session", params: { rfc: customer.rfc } }

  describe "GET /invoices/new" do
    it "renders the invoice form with the two default rows" do
      get "/invoices/new"

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Please add your products and click on Create:")
      expect(response.body).to include("Create Invoice")
      expect(response.body).to include("Item No. 1")
      expect(response.body).to include("Item No. 2")
    end
  end

  describe "POST /invoices" do
    let(:payload) do
      {
        invoice: {
          items_attributes: {
            "0" => { description: "aceite", quantity: "1", unit_price: "1000" },
            "1" => { description: "embudo", quantity: "3", unit_price: "500.50" }
          }
        }
      }
    end

    it "creates the invoice and shows the summary with computed totals" do
      expect { post "/invoices", params: payload }.to change(Invoice, :count).by(1)

      expect(response).to redirect_to(invoice_path(Invoice.last))

      get "/invoices/#{Invoice.last.uuid}"

      expect(response.body).to include("aceite")
      expect(response.body).to include("embudo")
      expect(response.body).to include("Subtotal")
      expect(response.body).to include("$2,501.50")
      expect(response.body).to include("$400.24")
      expect(response.body).to include("$2,901.74")
      expect(response.body).to include("No additional taxes are needed.")
    end

    it "discards the inactive second row when its quantity is zero" do
      payload[:invoice][:items_attributes]["1"][:quantity] = "0"

      post "/invoices", params: payload

      expect(Invoice.last.items.pluck(:description)).to eq(["aceite"])
    end

    it "re-renders the form when there are no products" do
      post "/invoices", params: { invoice: { items_attributes: {} } }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include("Please add your products and click on Create:")
      expect(response.body).to include("Item No. 1")
      expect(response.body).to include("Item No. 2")
    end

    it "flags additional taxes when a product tax exceeds the threshold" do
      payload[:invoice][:items_attributes]["0"][:unit_price] = "15000"
      payload[:invoice][:items_attributes]["1"][:quantity] = "0"

      post "/invoices", params: payload
      get "/invoices/#{Invoice.last.uuid}"

      expect(response.body).to include("Additional taxes are needed for this invoice.")
    end
  end

  describe "GET /invoices" do
    it "lists only the current customer's invoices" do
      mine = create_list(:invoice, 2, customer: customer)
      create_list(:invoice, 2, customer: other_customer)

      get "/invoices"

      expect(response).to have_http_status(:ok)
      mine.each { |invoice| expect(response.body).to include(invoice.uuid) }
      expect(response.body).to include("2 invoice(s) for RFC #{customer.rfc}")
    end

    it "shows an empty state when the customer has no invoices" do
      get "/invoices"

      expect(response.body).to include("No invoices yet.")
    end
  end

  describe "GET /invoices/:uuid" do
    it "returns 404 for another customer's invoice" do
      other = create(:invoice, customer: other_customer)

      expect { get "/invoices/#{other.uuid}" }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
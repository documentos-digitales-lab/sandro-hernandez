require 'rails_helper'

RSpec.describe CustomersController, type: :controller do
  describe "routing" do
    it { should route(:get, "/customers/new").to(action: :new) }
    it { should route(:post, "/customers").to(action: :create) }
    it { should route(:get, "/customers/1").to(action: :show, id: 1) }
    it { should route(:put, "/customers/1").to(action: :update, id: 1) }
  end

  describe "GET #new" do
    it "renders the view" do
      get :new

      expect(response).to render_template(:new)
      expect(response).to render_with_layout(:application)
    end
  end

  describe "POST #create" do
    it "creates a new customer" do
      expect { post(:create) }.to change(Customer, :count).by(1)
    end

    it "redirects to the customer show page" do
      customer = create(:customer, id: 1, rfc: 'AAA010101000')
      allow(Customer).to receive(:create).and_return(customer)

      post :create

      expect(Customer).to have_received(:create)
      expect(response).to redirect_to customer_path(1)
    end
  end

  describe "GET #show" do
    it "finds the customer" do
      customer = create(:customer, id: 1)
      allow(Customer).to receive(:find).with("1").and_return(customer)

      get :show, params: { id: 1 }

      expect(Customer).to have_received(:find).with("1")
    end

    it "shows the current customer" do
      customer = create(:customer, id: 1)
      allow(Customer).to receive(:create).and_return(customer)

      get :show, params: { id: 1 }

      expect(response).to render_template(:show)
      expect(response).to render_with_layout(:application)
    end
  end

  describe "PUT #update" do
    it "finds the customer" do
      customer = create(:customer, id: 1)
      allow(Customer).to receive(:find).with("1").and_return(customer)

      put :update, params: { id: 1 }

      expect(Customer).to have_received(:find).with("1")
    end

    it "redirects to the new customer page" do
      customer = create(:customer, id: 1)
      allow(Customer).to receive(:find).with("1").and_return(customer)

      put :update, params: { id: 1 }

      expect(response).to redirect_to new_customer_path
    end
  end
end

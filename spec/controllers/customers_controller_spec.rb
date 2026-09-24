require 'rails_helper'

RSpec.describe CustomersController, type: :controller do
  describe "routing" do
    it { should route(:get, "/customers/new").to(action: :new) }
    it { should route(:post, "/customers").to(action: :create) }
    it { should route(:get, "/customers/1").to(action: :show, id: 1) }
  end

  describe "authentication" do
    it "allows unauthenticated access to the registration actions" do
      get :new
      expect(response).to have_http_status(:ok)
    end

    it "redirects unauthenticated requests for protected actions" do
      get :show, params: { id: 1 }
      expect(response).to redirect_to(new_session_path)
    end
  end

  describe "GET #new" do
    it "renders the view" do
      get :new

      expect(response).to render_template(:new)
      expect(response).to render_with_layout(:application)
    end
  end

  describe "POST #create" do
    it "creates a new customer with the given RFC" do
      expect {
        post :create, params: { customer: { rfc: "ABC220101XYZ" } }
      }.to change(Customer, :count).by(1)
    end

    it "redirects to log in instead of auto-logging in" do
      post :create, params: { customer: { rfc: "ABC220101XYZ" } }

      expect(response).to redirect_to(new_session_path)
      expect(session[:customer_id]).to be_nil
    end

    it "re-renders the form when the RFC is invalid" do
      post :create, params: { customer: { rfc: "" } }

      expect(response).to render_template(:new)
    end

    it "re-renders the form when the RFC is already taken" do
      create(:customer, rfc: "ABC220101XYZ")

      post :create, params: { customer: { rfc: "ABC220101XYZ" } }

      expect(response).to render_template(:new)
      expect(assigns(:customer).errors[:rfc]).to include("has already been taken")
    end

    it "normalizes the RFC before storing it" do
      post :create, params: { customer: { rfc: "  abc220101xyZ  " } }

      expect(Customer.last.rfc).to eq("ABC220101XYZ")
    end
  end

  describe "GET #show" do
    let(:customer) { create(:customer) }

    before { session[:customer_id] = customer.id }

    it "renders the current customer dashboard for their own path" do
      get :show, params: { id: customer.id }

      expect(response).to render_template(:show)
      expect(response).to render_with_layout(:application)
    end

    it "redirects to the canonical dashboard when the id does not match" do
      get :show, params: { id: customer.id + 1 }

      expect(response).to redirect_to(customer_path(customer))
    end
  end
end
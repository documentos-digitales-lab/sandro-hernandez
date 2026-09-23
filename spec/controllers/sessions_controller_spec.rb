require "rails_helper"

RSpec.describe SessionsController, type: :controller do
  describe "GET #new" do
    it "renders the login view" do
      get :new

      expect(response).to render_template(:new)
      expect(response).to render_with_layout(:application)
    end
  end

  describe "POST #create" do
    let!(:customer) { create(:customer, rfc: "ABC220101XYZ") }

    context "with a known RFC" do
      it "logs the customer in and redirects to their dashboard" do
        post :create, params: { rfc: "abc220101xyz" }

        expect(session[:customer_id]).to eq(customer.id)
        expect(response).to redirect_to(customer_path(customer))
      end

      it "trims whitespace and ignores case when matching" do
        post :create, params: { rfc: "  ABC220101xyz  " }

        expect(session[:customer_id]).to eq(customer.id)
      end
    end

    context "with an unknown RFC" do
      it "does not start a session and re-renders login with an alert" do
        post :create, params: { rfc: "ZZZZ00000000" }

        expect(session[:customer_id]).to be_nil
        expect(response).to render_template(:new)
        expect(flash[:alert]).to eq("No account found with that RFC. Please register first.")
      end
    end

    context "with a blank RFC" do
      it "does not start a session" do
        post :create, params: { rfc: "  " }

        expect(session[:customer_id]).to be_nil
        expect(response).to render_template(:new)
      end
    end
  end

  describe "DELETE #destroy" do
    it "clears the session and redirects to the login page" do
      session[:customer_id] = create(:customer).id

      delete :destroy

      expect(session[:customer_id]).to be_nil
      expect(response).to redirect_to(root_path)
    end
  end
end
require "rails_helper"

RSpec.describe "Authentication flow", type: :request do
  it "redirects protected pages to login when not authenticated" do
    get "/invoices"
    expect(response).to redirect_to("/session/new")
    expect(flash[:alert]).to eq("Please log in to continue.")
  end

  it "registers a customer and requires a separate login" do
    expect {
      post "/customers", params: { customer: { rfc: "abc220101xyz" } }
    }.to change(Customer, :count).by(1)

    expect(response).to redirect_to("/session/new")
    expect(flash[:notice]).to eq("Account created. Please log in.")
  end

  it "shows an inline error when registering a duplicate RFC" do
    create(:customer, rfc: "ABC220101XYZ")

    expect {
      post "/customers", params: { customer: { rfc: "ABC220101XYZ" } }
    }.not_to change(Customer, :count)

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("has already been taken")
  end

  it "stores a normalized RFC on registration" do
    post "/customers", params: { customer: { rfc: "  abc220101xyz  " } }

    expect(Customer.last.rfc).to eq("ABC220101XYZ")
  end

  it "logs an existing customer in and logs them out" do
    customer = create(:customer, rfc: "ABC220101XYZ")

    post "/session", params: { rfc: customer.rfc }
    expect(response).to redirect_to("/customers/#{customer.id}")

    get "/invoices"
    expect(response).to have_http_status(:ok)

    delete "/session"
    expect(response).to redirect_to("/")

    get "/invoices"
    expect(response).to redirect_to("/session/new")
  end

  it "switches the navbar between anonymous and authenticated states" do
    get "/session/new"
    expect(response.body).to include("Log in")
    expect(response.body).to include("Create an account")
    expect(response.body).not_to include("Log out")

    customer = create(:customer, rfc: "ABC220101XYZ")
    post "/session", params: { rfc: customer.rfc }

    get "/invoices"
    expect(response.body).to include(customer.rfc)
    expect(response.body).to include("Log out")
    expect(response.body).not_to include("Log in")
  end
end
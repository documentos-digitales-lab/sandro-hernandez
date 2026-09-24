require "rails_helper"

RSpec.feature "A logged-in customer creates an invoice" do
  def log_in
    visit root_path
    click_on "Create an account"
    fill_in "RFC", with: "ABC220101XYZ"
    click_on "Register"
    fill_in "rfc", with: "ABC220101XYZ"
    click_on "Sign in"
  end

  def create_invoice
    fill_in "invoice_items_attributes_0_description", with: "aceite"
    fill_in "invoice_items_attributes_0_unit_price", with: "1000"
    click_on "Create Invoice"
  end

  scenario "stores the products and computes tax" do
    log_in

    click_on "Create An Invoice"
    expect(page).to have_content("Please add your products and click on Create:")

    create_invoice

    expect(page).to have_content "aceite"
    expect(page).to have_content "$1,000.00"
    expect(page).to have_content "$1,160.00"
  end

  scenario "lists the customer's invoices" do
    log_in

    click_on "Create An Invoice"
    create_invoice

    visit invoices_path

    expect(page).to have_content "Invoices"
    expect(page).to have_content "1 product"
    expect(page).to have_content "$1,160.00"
  end
end
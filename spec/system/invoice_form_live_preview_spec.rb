require "rails_helper"

# End-to-end coverage of the Stimulus preview in the invoice form (Part 1):
# live money math, the additional-taxes banner and the submit guard.
RSpec.describe "Invoice form live preview", type: :system do
  def log_in
    visit root_path
    click_on "Create an account"
    fill_in "RFC", with: "ABC220101XYZ"
    click_on "Register"
    fill_in "rfc", with: "ABC220101XYZ"
    click_on "Sign in"
  end

  it "recomputes amounts, tax and total as the customer types" do
    log_in
    click_on "Create An Invoice"

    expect(find("[data-invoice-form-target='subtotal']").text).to eq("$0.00")

    find("#invoice_items_attributes_0_description").set("aceite")
    find("#invoice_items_attributes_0_quantity").set(2)
    find("#invoice_items_attributes_0_unit_price").set(1000)

    expect(find_all("[data-invoice-form-target='amount']").first.text).to eq("$2,000.00")
    expect(find("[data-invoice-form-target='subtotal']").text).to eq("$2,000.00")
    expect(find("[data-invoice-form-target='tax']").text).to eq("$320.00")
    expect(find("[data-invoice-form-target='total']").text).to eq("$2,320.00")
  end

  it "warns, blocks the submit and recovers when a product tax crosses the threshold" do
    log_in
    click_on "Create An Invoice"

    find("#invoice_items_attributes_0_description").set("laptop")
    find("#invoice_items_attributes_0_quantity").set(1)
    find("#invoice_items_attributes_0_unit_price").set(15000)

    expect(find("[data-invoice-form-target='banner']"))
      .to have_content("Additional taxes are needed for this invoice.")
    expect(find_button("Create Invoice", disabled: :all)).to be_disabled

    find("#invoice_items_attributes_0_unit_price").set(500)

    expect(find("[data-invoice-form-target='banner']"))
      .to have_content("No additional taxes are needed.")
    expect(find_button("Create Invoice", disabled: :all)).not_to be_disabled
  end
end
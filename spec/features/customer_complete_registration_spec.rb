require "rails_helper"

RSpec.feature "A customer checks into the app" do
  scenario "registers, logs in and reaches the invoice form" do
    visit root_path

    click_on "Create an account"
    fill_in "RFC", with: "ABC220101XYZ"
    click_on "Register"

    expect(page).to have_content "Account created. Please log in."

    fill_in "rfc", with: "ABC220101XYZ"
    click_on "Sign in"

    expect(page).to have_content "Please complete all of the steps on this page"

    click_on "Create An Invoice"

    expect(page).to have_content("Please add your products and click on Create:")
  end

  scenario "is sent to the login page when trying to use the app" do
    visit new_invoice_path

    expect(page).to have_content("Log in")
    expect(page).to have_content("Please log in to continue.")
  end
end
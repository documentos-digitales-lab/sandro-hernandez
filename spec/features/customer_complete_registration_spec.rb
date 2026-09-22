require "rails_helper"

RSpec.feature "A customer checks into the app" do
  scenario "for a scheduled appointment" do
    visit root_path

    click_on "Start app"

    expect(page).to have_content "Please complete all of the steps on this page"

    click_on "Create An Invoice"

    expect(page).to have_content("Please add your products and click on Create:")
  end
end

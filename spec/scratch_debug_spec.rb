require "rails_helper"

RSpec.describe SessionsController, type: :controller do
  it "debug exact rfc" do
    customer = create(:customer, rfc: "ABC220101XYZ")
    puts "created id=#{customer.id} rfc=#{customer.rfc.inspect}"
    post :create, params: { rfc: "abc220101xyz" }
    puts "status=#{response.status} redirect=#{response.location.inspect} alert=#{flash[:alert].inspect}"
    puts "session=#{session[:customer_id].inspect}"
    puts "found=#{Customer.find_by(rfc: 'ABC220101XYZ')&.id.inspect}"
    Customer.where(rfc: "ABC220101XYZ").delete_all
  end
end
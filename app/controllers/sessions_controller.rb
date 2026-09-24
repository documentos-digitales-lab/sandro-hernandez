class SessionsController < ApplicationController
  skip_before_action :require_customer

  def new
  end

  def create
    customer = Customer.find_by(rfc: params[:rfc].to_s.strip.upcase)

    if customer
      session[:customer_id] = customer.id
      profile = UserProfileLoader.call(customer_id: customer.id)
      session[:user_profile] = profile.to_h&.stringify_keys
      flash[:welcome] = welcome_message(profile) if profile.present?
      redirect_to customer_path(customer)
    else
      flash.now[:alert] = "No account found with that RFC. Please register first."
      render :new
    end
  end

  def destroy
    reset_session
    redirect_to root_path
  end

  private

  def welcome_message(profile)
    "Welcome, #{profile.full_name}. It's so great to see you again."
  end
end
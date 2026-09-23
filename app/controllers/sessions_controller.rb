class SessionsController < ApplicationController
  skip_before_action :require_customer

  def new
  end

  def create
    customer = Customer.find_by(rfc: params[:rfc].to_s.strip.upcase)

    if customer
      session[:customer_id] = customer.id
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
end
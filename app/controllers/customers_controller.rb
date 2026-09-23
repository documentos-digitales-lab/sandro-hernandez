class CustomersController < ApplicationController
  skip_before_action :require_customer, only: [:new, :create]

  def new
  end

  def show
    @customer = current_customer
  end

  def create
    @customer = Customer.new(customer_params)

    if @customer.save
      redirect_to new_session_path, notice: "Account created. Please log in."
    else
      render :new
    end
  end

  def update
    Customer.find(params[:id])
    redirect_to new_customer_path
  end

  private

  def customer_params
    params.require(:customer).permit(:rfc)
  end
end
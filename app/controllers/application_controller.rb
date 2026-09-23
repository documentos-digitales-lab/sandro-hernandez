class ApplicationController < ActionController::Base
  before_action :require_customer

  helper_method :current_customer

  private

  def current_customer
    @current_customer ||= Customer.find_by(id: session[:customer_id])
  end

  def require_customer
    redirect_to new_session_path, alert: "Please log in to continue." unless current_customer
  end
end
class ApplicationController < ActionController::Base
  before_action :require_customer

  helper_method :current_customer, :current_user_profile

  private

  def current_customer
    @current_customer ||= Customer.find_by(id: session[:customer_id])
  end

  def current_user_profile
    @current_user_profile ||= begin
      data = session[:user_profile]
      if data && data["full_name"].present?
        UserProfile.new(full_name: data["full_name"], image_url: data["image_url"])
      else
        UserProfile.null
      end
    end
  end

  def require_customer
    redirect_to new_session_path, alert: "Please log in to continue." unless current_customer
  end
end
class ApplicationController < ActionController::Base
  before_action :require_customer
  before_action :load_user_profile

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

  def load_user_profile
    return unless current_customer
    return if session.key?(:user_profile)

    profile = UserProfileLoader.call(customer_id: current_customer.id)
    session[:user_profile] = profile.to_h&.stringify_keys
    flash.now[:welcome] = welcome_message(profile) if profile.present?
  rescue ExternalUserClient::Error
    session[:user_profile] = { "full_name" => nil, "image_url" => nil }
  end

  def welcome_message(profile)
    "Welcome, #{profile.full_name}. It's so great to see you again."
  end
end
class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session
  helper_method :resource, :collection, :signed_in?

  def signed_in?
    not request.authorization.nil?
  end

  protected

  def authenticate!
    if Rails.env == "production"
      authenticate_or_request_with_http_basic do |username, password|
        username == ENV["HTTP_USER"] && password == ENV["HTTP_PASSWORD"]
      end
    end
  end
end

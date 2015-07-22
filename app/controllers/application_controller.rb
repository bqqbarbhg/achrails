class ApplicationController < ActionController::Base
  include Pundit
  
  # CSRF breaks dev login, but it's not needed in dev environment anyway
  if Rails.env.production?
    # Prevent CSRF attacks by raising an exception.
    # For APIs, you may want to use :null_session instead.
    protect_from_forgery with: :null_session
  end

  # before_action :authenticate_user!

  def render_forbidden
    # TODO: Real forbidden
    render nothing: true, status: :forbidden
  end

  rescue_from Pundit::NotAuthorizedError, with: :render_forbidden
end

class ApplicationController < ActionController::Base
  include Pundit
  
  # CSRF breaks dev login, but it's not needed in dev environment anyway
  if Rails.env.production?
    # Prevent CSRF attacks by raising an exception.
    # For APIs, you may want to use :null_session instead.
    protect_from_forgery with: :null_session
  end

  # Visitors can view public content without having to authenticate, authentication
  # checks are mostly done now in policies or per route authenticate_user! calls.
  # before_action :authenticate_user!


  after_filter :store_location

  def store_location
    # store last url - this is needed for post-login redirect to whatever the user last visited.
    return unless request.get? 
    if (request.path != "/users/sign_in" &&
        request.path != "/users/sign_up" &&
        request.path != "/users/password/new" &&
        request.path != "/users/password/edit" &&
        request.path != "/users/confirmation" &&
        request.path != "/users/sign_out" &&
        !request.xhr?) # don't store ajax calls
      session[:previous_url] = request.fullpath 
    end
  end

  def render_forbidden
    # TODO: Real forbidden
    render nothing: true, status: :forbidden
  end

  def render_sss_error
    # TODO: Real SSS error
    render nothing: true, status: :internal_server_error
  end

  # Try to return back to the page the login originated from
  def after_sign_in_path_for(resource)
    session[:previous_url] || request.env['omniauth.origin'] || super
  end

  def reauthenticate
    respond_to do |format|
      format.json do
        render nothing: true, status: :unauthorized
      end
      format.html do
        redirect_to user_omniauth_authorize_url(:learning_layers_oidc, protocol: 'https')
      end
    end
  end

  def sss(user=nil)
    return nil unless SSS

    user ||= current_user

    @sss ||= begin
      sss_url = ENV["SSS_URL"]
      bearer = user.bearer_token
      SocialSemanticServer.new(sss_url, bearer) if sss_url
    end
  end

  rescue_from Pundit::NotAuthorizedError, with: :render_forbidden
  rescue_from SssConnectError, with: :reauthenticate
  rescue_from SssInternalError, with: :render_sss_error
end

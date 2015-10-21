class ApplicationController < ActionController::Base
  include Pundit

  before_action :get_refresh_token_from_header
  
  # CSRF breaks dev login, but it's not needed in dev environment anyway
  if Rails.env.production?
    # Prevent CSRF attacks by raising an exception.
    # For APIs, you may want to use :null_session instead.
    protect_from_forgery with: :null_session
  end

  # Visitors can view public content without having to authenticate, authentication
  # checks are mostly done now in policies or per route authenticate_user! calls.
  # before_action :authenticate_user!

  def get_refresh_token_from_header
    refresh_token = request.headers['HTTP_X_REFRESH_TOKEN']
    session['ll_oidc_refresh_token'] = refresh_token if refresh_token
  end

  def authenticate_and_redirect_back
    return false if current_user
    force_authenticate_and_redirect_back
  end

  def force_authenticate_and_redirect_back
    store_location_for(:user, request.fullpath)
    if Rails.env.production?
      if current_user
        refresh_token = session["ll_oidc_refresh_token"]
        if refresh_token && !@reauthenticated
          client = OAuth2::Client.new(ENV["LL_OIDC_CLIENT_ID"], ENV["LL_OIDC_CLIENT_SECRET"],
                                      site: ENV["LL_OIDC_HOST"],
                                      token_url: "/o/oauth2/token")
          token = client.get_token({
            client_id: client.id,
            client_secret: client.secret,
            grant_type: 'refresh_token',
            refresh_token: refresh_token})

          if token
            current_user.bearer_token = token.token
            current_user.save!
            session["ll_oidc_refresh_token"] = token.refresh_token
            @reauthenticated = true
            make_sss(current_user)
            send(action_name)
            return true
          end
        end
      end
      redirect_to user_omniauth_authorize_url(:learning_layers_oidc, protocol: 'https')
      true
    else
      false
    end
  end

  def render_exception_forbidden(exception)
    logger.error exception.message
    logger.error exception.backtrace.join "\n"
    render_forbidden
  end

  def render_forbidden(explanation='')
    @explanation = explanation
    render "shared/forbidden", status: :forbidden
  end

  def render_sss_error(exception)
    @sss_error = exception.message
    render "shared/sss_error", status: :internal_server_error
  end

  # Try to return back to the page the login originated from
  def after_sign_in_path_for(resource)
    stored_location_for(:user) || request.env['omniauth.origin'] || super
  end

  def reauthenticate
    respond_to do |format|
      format.json do
        render nothing: true, status: :unauthorized
      end
      format.html do
        force_authenticate_and_redirect_back
      end
    end
  end

  def sss(user=nil)
    return nil unless SSS

    user ||= current_user

    raise SssConnectError unless user

    @sss || make_sss(user)
  end

  def sss?
    return SSS
  end

  def make_sss(user)
    @sss = begin
      sss_url = FORCE_SSS_URL || ENV["SSS_URL"]
      bearer = FORCE_BEARER || user.bearer_token
      SocialSemanticServer.new(sss_url, bearer, user.sss_id) if sss_url
    end
  end

  rescue_from Pundit::NotAuthorizedError, with: :render_exception_forbidden
  rescue_from SssConnectError, with: :reauthenticate
  rescue_from SssInternalError, with: :render_sss_error
end

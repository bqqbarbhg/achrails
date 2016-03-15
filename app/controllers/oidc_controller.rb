# A _very_ minimal OIDC server implementation

class OidcError < StandardError; end

class OidcController < ApplicationController

  def show_authorize
    fail OidcError, 'response_type must be included in this request' unless params[:response_type]
    fail OidcError, 'Oauth only supports code flow at the moment' unless params[:response_type] == 'code'

    # Store user state
    state = params[:state]
    redirect_uri = params[:redirect_uri]
    client_id = params[:client_id]

    fail OidcError, 'client_id must be included in this request' unless client_id
    fail OidcError, 'redirect_uri must be included in this request' unless redirect_uri

    @link_state = {
      state: state,
      acr_redirect_uri: redirect_uri,
      acr_client_id: client_id,
    }

    render
  end

  def id_token_for(session)
    {
      iss: request.protocol + request.host,
      sub: session.user.token,
      aud: session.client_id,
      jti: SecureRandom.uuid,
      exp: session.expires_at.to_i,
      iat: Time.now.to_i,
    }
  end

  def token

    response.headers['Cache-Control'] = 'no-store'
    response.headers['Pragma'] = 'no-cache'

    client_id, client_secret = authenticate_with_http_basic { |u, p| [u, p] }
    client_id ||= params[:client_id]
    client_secret ||= params[:client_secret]

    fail OidcError, 'client_id must be included in this request' if client_id.blank?
    fail OidcError, 'client_secret must be included in this request' if client_secret.blank?

    case params[:grant_type]
    when 'authorization_code'

      code = params[:code]
      fail OidcError, 'code must be included in this request' if code.nil?

      session = Session.find_by_code(code)
      fail OidcError, 'Session not found' if session.nil?
      fail OidcError, 'Invalid client_id' if session.client_id != client_id
      fail OidcError, 'Session has expired' if session.expired?

      session.activate!

      render json: {
        token_type: 'Bearer',
        access_token: session.access_token,
        refresh_token: session.refresh_token,
        expires_in: session.expires_in.to_i,
        id_token: JWT.encode(id_token_for(session), client_secret, 'HS256'),
      }

    when 'refresh_token'
      
      refresh_token = params[:refresh_token]
      fail OidcError, 'refresh_token must be included in this request' if refresh_token.nil?

      session = Session.find_by_refresh_token(refresh_token)
      fail OidcError, 'Session not found' if session.nil?
      fail OidcError, 'Invalid client_id' if session.client_id != client_id

      session.refresh!

      render json: {
        token_type: 'Bearer',
        access_token: session.access_token,
        refresh_token: session.refresh_token,
        expires_in: session.expires_in.to_i,
        id_token: JWT.encode(id_token_for(session), client_secret, 'HS256'),
      }

    else
      fail OidcError, 'Unknown grant_type'
    end
  end

  def userinfo

    if current_user.nil?
      render json: {
        error: :access_denied,
        error_description: 'User not signed in',
      }, status: 401
      return
    end

    render json: {
      sub: current_user.token,
      name: current_user.name,
      preferred_username: current_user.preferred_username,
    }.delete_if { |k, v| v.nil? }

  end

  def end_session

    session_id = request.env["achrails.session_id"]
    session = session_id ? Session.find_by_id(session_id) : nil
    if session.nil?
      render json: {
        error: :access_denied,
        error_description: 'User not signed in',
      }, status: :unauthorized
      return
    end

    session.destroy
    render nothing: true, status: :no_content
  end

  rescue_from OidcError do |exception|
    render json: {
      error: :invalid_request,
      error_description: exception.message,
    }
  end

end


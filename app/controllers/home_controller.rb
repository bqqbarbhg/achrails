
class HomeController < ApplicationController

  def index
    render
  end

  def oidc_error
    expected_actions = {
      "log_in" => ["openid", "profile", "email"],
      "accept_invitation" => ["email"],
    }

    failed_action = params["failed_action"]
    infos = expected_actions[failed_action]
    if infos.present?
      @failed_action = failed_action
      @infos = infos
    else
      @failed_action = 'generic'
      @infos = nil
    end

    render
  end

  def oidc_tokens
    render nothing: true, status: :not_found and return unless ENV["SHOW_OIDC_TOKENS"]

    render json: {
      client_id: ENV["ACHRAILS_OIDC_CLIENT_ID"],
      client_secret: ENV["ACHRAILS_OIDC_CLIENT_SECRET"],
    }
  end

  def show_user
    authenticate_user!
    render json: current_user.manifest_json
  end

  def new_session
    render
  end

end


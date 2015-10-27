
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

end


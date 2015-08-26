
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
      @failed_action = "action_fail." + failed_action
      @infos = infos.map { |info| "user_info." + info }
    else
      @failed_action = "action_fail.generic"
      @infos = nil
    end

    render
  end

end


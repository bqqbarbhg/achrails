class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController

  def learning_layers_oidc
    @user = User.from_omniauth(request.env["omniauth.auth"])
    
    if @user.nil?
      redirect_to oidc_action_error_path(failed_action: "log_in")
      return
    end

    params = request.env["omniauth.params"]
    if params['acr_redirect_uri']

      s = Session.create_code_auth(user: @user, client_id: params['acr_client_id'])

      request.env["achrails.session_code"] = s.code
      request.env["achrails.session_state"] = params['state'] if params['state']
    end

    user_sss = sss(@user)
    if user_sss
      @user.sss_id = user_sss.current_user_sss_id
      @user.save!
    end

    if @user.persisted?
      sign_in_and_redirect @user, :event => :authentication #this will throw if @user is not activated
      set_flash_message(:notice, :success, :kind => "Learning Layers") if is_navigational_format?
    else
      session["devise.learning_layers_oidc_data"] = request.env["omniauth.auth"]
      redirect_to new_user_registration_url
    end
  end

  def developer
    @user = User.from_omniauth(request.env["omniauth.auth"])

    if @user.nil?
      redirect_to oidc_action_error_path(failed_action: "log_in")
      return
    end

    params = request.env["omniauth.params"]
    if params['acr_redirect_uri']

      s = Session.create_code_auth(user: @user, client_id: params['acr_client_id'])

      request.env["achrails.session_code"] = s.code
      request.env["achrails.session_state"] = params['state'] if params['state']
    end

    if @user.persisted?
      sign_in_and_redirect @user, :event => :authentication #this will throw if @user is not activated
      set_flash_message(:notice, :success, :kind => "Developer") if is_navigational_format?
    else
      session["devise.developer_data"] = request.env["omniauth.auth"]
      redirect_to new_user_registration_url
    end
  end

  def google_oauth2
    @user = User.from_omniauth(request.env["omniauth.auth"])

    if @user.nil?
      redirect_to oidc_action_error_path(failed_action: "log_in")
      return
    end

    params = request.env["omniauth.params"]
    if params['acr_redirect_uri']

      s = Session.create_code_auth(user: @user, client_id: params['acr_client_id'])

      request.env["achrails.session_code"] = s.code
      request.env["achrails.session_state"] = params['state'] if params['state']
    end

    if @user.persisted?
      sign_in_and_redirect @user, :event => :authentication #this will throw if @user is not activated
      set_flash_message(:notice, :success, :kind => "Google") if is_navigational_format?
    else
      session["devise.developer_data"] = request.env["omniauth.auth"]
      redirect_to new_user_registration_url
    end
  end

end

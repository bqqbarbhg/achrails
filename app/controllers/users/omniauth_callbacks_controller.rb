class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  
  def base_authorize_user
    @user = User.from_omniauth(request.env["omniauth.auth"])
    if @user.nil?
      redirect_to oidc_action_error_path(failed_action: "log_in")
      return
    end

    # If the Omniauth params contain acr_redirect_uri, the auth originated from /oidc/authorize
    # After authorization redirect the user to the specified URI with a new session code
    params = request.env["omniauth.params"]
    if params['acr_redirect_uri']
      s = Session.create_code_auth(user: @user, client_id: params['acr_client_id'])
      request.env["achrails.session_code"] = s.code
      request.env["achrails.session_state"] = params['state'] if params['state']
    end
  end

  def base_redirect_user
    provider = request.env["omniauth.auth"].provider

    if @user.persisted?
      sign_in_and_redirect @user, :event => :authentication #this will throw if @user is not activated
      set_flash_message(:notice, :success, :kind => provider) if is_navigational_format?
      flash[:notice] = t(provider, scope: 'signed_in')
    else
      session["devise.developer_data"] = request.env["omniauth.auth"]
      redirect_to new_user_registration_url
    end
  end

  def base_provider
    base_authorize_user
    base_redirect_user
  end

  def learning_layers_oidc
    authorize_user

    user_sss = sss(@user)
    if user_sss
      @user.sss_id = user_sss.current_user_sss_id
      @user.save!
    end

    base_redirect_user(:learning_layers_oidc)
  end

  # Add methods for providers
  for provider in Devise.omniauth_providers
    next if method_defined? provider
    alias_method provider, :base_provider
  end

end

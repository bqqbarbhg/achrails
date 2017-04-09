class NotificationsController < ApplicationController
  def register_token
    authenticate_user!

    token = params[:registration_token]

    if token
        current_user.add_device_token(token)
    end

    render :status => 200
  end

  def unregister_token
    authenticate_user!

    token = params[:registration_token]

    if token
        current_user.remove_device_token(token)
    end

    render :status => 200
  end
end

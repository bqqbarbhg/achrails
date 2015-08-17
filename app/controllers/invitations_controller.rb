
class InvitationsController < ApplicationController

  def show
    authenticate_user!

    @invitation = Invitation.find_by(token: params[:id])
    @group = @invitation.group

    if current_user && current_user.email.blank?
      redirect_to oidc_action_error_path(failed_action: "accept_invitation")
      return
    end

    unless @invitation.can_join?(current_user)
      render status: :forbidden
      return
    end

    # TODO: SSS invitations
    @group.join(current_user)
    @invitation.destroy
    
    redirect_to @group
  end

protected
end


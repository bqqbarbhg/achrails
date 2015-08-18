
class InvitationsController < ApplicationController

  def show
    authenticate_user!

    @invitation = Invitation.find_by(token: params[:id])
    if current_user && current_user.email.blank?
      redirect_to oidc_action_error_path(failed_action: "accept_invitation")
      return
    end

    unless @invitation.can_join?(current_user)
      render_forbidden
      return
    end

    # TODO: SSS invitations
    if sss
      sss.join_group(@invitation.sss_group, current_user)
    else
      @group = @invitation.group
      @group.join(current_user)
    end
    @invitation.destroy
    
    redirect_to @group
  end

protected
end


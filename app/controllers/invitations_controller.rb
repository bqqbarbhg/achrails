
class InvitationsController < ApplicationController

  def show
    authenticate_user!

    @invitation = Invitation.find_by(token: params[:id])
    if sss
      @group = sss.group(@invitation.sss_group)
    else
      @group = @invitation.group
    end

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
      sss.join_group(@group, current_user)
    else
      @group.join(current_user)
    end
    @invitation.destroy
    
    redirect_to @group
  end

protected
end



class InvitationsController < ApplicationController

  def show
    return if authenticate_and_redirect_back

    @invitation = Invitation.find_by(token: params[:id])
    if current_user && current_user.email.blank?
      redirect_to oidc_action_error_path(failed_action: "accept_invitation")
      return
    end

    unless @invitation.can_join?(current_user)
      render_forbidden
      return
    end

    if sss
      sss.join_group(@invitation.sss_group, current_user)
      @group = sss.group(@invitation.sss_group)
    else
      @group = @invitation.group
      @group.join(current_user)
    end
    @invitation.destroy

    redirect_to @group, notice: t(:joined_group, group: @group.name)
  end

protected
end


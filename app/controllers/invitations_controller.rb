
class InvitationsController < ApplicationController

  def show
    return if authenticate_and_redirect_back

    @invitation = Invitation.find_by(token: params[:id])
    if current_user && current_user.email.blank?
      redirect_to oidc_action_error_path(failed_action: "accept_invitation")
      return
    end

    unless @invitation.can_join?(current_user)
      render_forbidden t(:invite_email_expected, email: @invitation.expect_email)
      return
    end

    @group = @invitation.group
    sss.join_group(@group, current_user) if sss
    @group.join(current_user)
    @invitation.destroy

    redirect_to @group, notice: t(:joined_group, group: @group.name)
  end

protected
end


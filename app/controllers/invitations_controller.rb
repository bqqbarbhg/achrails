
class InvitationsController < ApplicationController

  def show
    return if authenticate_and_redirect_back

    @invitation = Invitation.find_by(token: params[:id])
    unless @invitation
      group = Group.find_by_id(Invitation.group_from_token(params[:id]))
      if group.nil?
        redirect_to controller: :groups, action: :index
      else
        redirect_to group
      end
      return
    end

    if current_user && current_user.email.blank?
      redirect_to oidc_action_error_path(failed_action: "accept_invitation")
      return
    end

    unless @invitation.can_join?(current_user)
      render_forbidden t('invitations.error_expected_email',
                         email: @invitation.expect_email)
      return
    end

    @group = @invitation.group

    log_event(:join_group, @group)

    sss.join_group(@group, current_user) if sss
    @group.join(current_user)
    @invitation.destroy

    redirect_to @group, notice: t('invitations.joined_message',
                                  group: @group.name)
  end

protected
end


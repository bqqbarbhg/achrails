class InvitationMailer < ApplicationMailer
  def invite_email(invitation)
    @email = invitation.expect_email
    @url = invitation_url(invitation)
    if sss
      @group = sss.group(invitation.sss_group)
    else
      @group = invitation.group
    end
    mail to: @email, subject: "You have been invited to: #{@group.name}"
  end
end

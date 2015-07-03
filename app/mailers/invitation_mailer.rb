class InvitationMailer < ApplicationMailer
  def invite_email(invitation)
    @email = invitation.expect_email
    @url = invitation_url(invitation)
    @group = invitation.group
    mail to: @email, subject: "You have been invited to: #{@group.name}"
  end
end

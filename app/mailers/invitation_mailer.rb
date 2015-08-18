class InvitationMailer < ApplicationMailer
  def invite_email(invitation, group)
    @email = invitation.expect_email
    @url = invitation_url(invitation)
    mail to: @email, subject: "You have been invited to: #{group.name}"
  end
end

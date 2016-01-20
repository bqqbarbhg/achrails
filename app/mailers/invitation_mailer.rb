class InvitationMailer < ApplicationMailer
  def invite_email(invitation, group_name, inviter)
    @email = invitation.expect_email
    @url = invitation_url(invitation, locale: nil)
    @group_name = group_name
    @inviter = inviter
    mail to: @email, subject: "You have been invited to: #{group_name}"
  end
end

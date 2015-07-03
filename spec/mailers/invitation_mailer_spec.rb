
RSpec.describe InvitationMailer do

  describe 'invitation' do
    before do
      @group = Group.create!(name: 'test')
      @invitation = Invitation.create!(expect_email: 'test@example.com',
                                       group: @group)
      @mail = InvitationMailer.invite_email(@invitation)
    end

    it 'contains the link to the invitation' do
      url = invitation_url(@invitation)
      expect(@mail.body.encoded).to match(url)
    end
  end
end


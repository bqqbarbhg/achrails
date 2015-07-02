
RSpec.describe GroupsController do

  describe 'POST /groups' do
    before do
      @user = User.create!(email: 'test@example.com', password: 'testtest')
      sign_in @user
      post :create, group: { name: 'test' }
      @group = assigns(:group)
    end

    it 'redirects to the group' do
      expect(response).to redirect_to(group_path(@group))
    end
    it 'makes the current user a member' do
      expect(@group.member(@user)).not_to be_nil
    end
    it 'makes the current user an admin' do
      expect(@group.admin?(@user)).to be true
    end
  end
end


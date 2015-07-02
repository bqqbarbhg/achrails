
RSpec.describe HomeController do

  let(:user) { nil }

  before do
    sign_in user if user
    get :index
  end

  context 'not logged in' do
    it 'redirects to login page' do
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  context 'logged in' do
    let(:user) { User.create!(email: 'test@example.com', password: 'testtest') }

    it 'renders the index' do
      expect(response).to render_template(:index)
    end

  end

end


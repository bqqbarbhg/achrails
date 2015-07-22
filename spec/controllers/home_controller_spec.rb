
RSpec.describe HomeController do

  let(:user) { nil }

  before do
    sign_in user if user
    get :index
  end

  context 'logged in' do
    let(:user) { User.create!(email: 'test@example.com', uid: '1', provider: 'test') }

    it 'renders the index' do
      expect(response).to render_template(:index)
    end

  end

end


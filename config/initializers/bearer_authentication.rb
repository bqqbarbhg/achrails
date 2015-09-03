
class LearningLayersUser
  class UserInfo < Struct.new(:email, :name)
  end
  class Extra < Struct.new(:bearer, :refresh)
  end

  attr_reader :uid
  attr_reader :provider
  attr_reader :info
  attr_reader :extra

  def initialize(hash, bearer, refresh)
    @uid = hash['sub']
    @provider = 'learning_layers_oidc'

    @info = UserInfo.new(hash['email'], hash['name'])
    @extra = Extra.new(bearer, refresh)
  end
end

Warden::Strategies.add(:bearer_authentication) do
  def valid?
    bearer
  end

  def authenticate!
    client = OAuth2::Client.new(ENV["LL_OIDC_CLIENT_ID"], ENV["LL_OIDC_CLIENT_SECRET"],
                                site: ENV["LL_OIDC_HOST"],
                                token_url: "/o/oauth2/token")

    token = OAuth2::AccessToken.new(client, bearer,
      refresh_token: request.headers['HTTP_X_REFRESH_TOKEN'])

    response = token.get('/o/oauth2/userinfo')
    user_info = LearningLayersUser.new(response.parsed, bearer, token.refresh_token) if response
    
    if user_info
      user = User.from_omniauth(user_info)
      success!(user)
    else
      fail
    end
  rescue OAuth2::Error
    begin
      token = token.refresh!
      response = token.get('/o/oauth2/userinfo')
      user_info = LearningLayersUser.new(response.parsed, bearer, token.refresh_token)

      if user_info
        user = User.from_omniauth(user_info)
        success!(user)
      else
        fail
      end
    rescue OAuth2::Error
      fail
    end
  end

protected

  def authorization
    request.authorization
  end

  def bearer
    @bearer ||= begin
      auth = authorization
      if auth
        tokens = auth.split(/\s+/, 2)
        tokens[1] if tokens.length == 2 && tokens[0].downcase == 'bearer'
      end
    end
  end
end


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

  def try_log_in(token)
    response = token.get('/o/oauth2/userinfo')
    user_info = LearningLayersUser.new(response.parsed, bearer, token.refresh_token) if response
    return false unless user_info
    user = User.from_omniauth(user_info)
    return false unless user
    success!(user)
    true
  rescue OAuth2::Error
    false
  end

  def authenticate!
    client = OAuth2::Client.new(ENV["ACHRAILS_OIDC_CLIENT_ID"], ENV["ACHRAILS_OIDC_CLIENT_SECRET"],
                                site: ENV["LAYERS_API_URI"].chomp('/'),
                                token_url: "/o/oauth2/token")

    token = OAuth2::AccessToken.new(client, bearer,
      refresh_token: request.headers['HTTP_X_REFRESH_TOKEN'])

    return if try_log_in(token)
    return if token.refresh_token and try_log_in(token.refresh!)

    fail
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

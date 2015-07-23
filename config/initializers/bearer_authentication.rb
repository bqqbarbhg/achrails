
class LearningLayersUser
  class UserInfo < Struct.new(:email)
  end

  attr_reader :uid
  attr_reader :provider
  attr_reader :info

  def initialize(hash)
    @uid = hash['sub']
    @provider = 'learning_layers_oidc'

    @info = UserInfo.new(hash['email'])
  end
end

Warden::Strategies.add(:bearer_authentication) do
  def valid?
    bearer
  end

  def authenticate!
    client = OAuth2::Client.new(ENV["LL_OIDC_CLIENT_ID"], ENV["LL_OIDC_CLIENT_SECRET"],
                                site: ENV["LL_OIDC_HOST"])

    token = OAuth2::AccessToken.new(client, bearer)
    user_info_hash = token.get('/o/oauth2/userinfo').parsed
    user_info = LearningLayersUser.new(user_info_hash) if user_info_hash

    # TODO: Better check here

    if user_info
      user = User.from_omniauth(user_info)
      success!(user)
    else
      fail
    end
  end

protected

  def authorization
    Rails.logger.debug request.authorization
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

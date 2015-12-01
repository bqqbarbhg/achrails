require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class LearningLayersOidc < OmniAuth::Strategies::OAuth2
      option :name, "learning_layers_oidc"
      option :client_options,
        site: (ENV["LAYERS_API_URI"] || '').chomp('/'),
        authorize_url: "/o/oauth2/authorize",
        token_url: "/o/oauth2/token"
      
      uid do
        raw_info['sub']
      end

      info do
        {
          email: raw_info['email'],
          name: raw_info['name'],
          given_name: raw_info['given_name'],
          family_name: raw_info['family_name'],
          preferred_username: raw_info['preferred_username']
        }
      end

      extra do
        {
          bearer: access_token.token,
          refresh: access_token.refresh_token,
        }
      end

      def raw_info
        @raw_info ||= access_token.get('/o/oauth2/userinfo').parsed
      end
    end
  end
end

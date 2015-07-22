require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class LearningLayersOidc < OmniAuth::Strategies::OAuth2
      option :name, "learning_layers_oidc"
      option :client_options,
        site: ENV["LL_OIDC_HOST"],
        authorize_url: "/o/oauth2/authorize",
        token_url: "/o/oauth2/token"
      
      uid do
        raw_info['id']
      end

      info do
        {
          email: raw_info['email']
        }
      end

      extra do
        {
          'raw_info': raw_info
        }
      end

      def raw_info
        @raw_info ||= access_token.get('/o/oauth2/userinfo').parsed
      end
    end
  end
end

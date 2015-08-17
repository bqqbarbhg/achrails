if SSS
class User < ActiveRecord::Base
  devise :rememberable, :omniauthable,
    omniauth_providers: if Rails.env.production?
                          [:learning_layers_oidc]
                        else
                          [:developer]
                        end

  def self.from_omniauth(auth)
    return nil if [auth.info.name, auth.provider, auth.uid].any? &:blank?

    user = where(provider: auth.provider, uid: auth.uid).first_or_create
    user.bearer_token = auth.extra.try(:bearer)
    user.save!
    user
  end

end
end

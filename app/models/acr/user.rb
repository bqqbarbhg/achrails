unless SSS
class User < ActiveRecord::Base
  devise :rememberable, :omniauthable,
    omniauth_providers: if Rails.env.production?
                          [:learning_layers_oidc]
                        else
                          [:developer]
                        end

  has_many :memberships
  has_many :groups, through: :memberships, source: :group
  has_many :videos, through: :groups

  has_many :authored_videos, class_name: "Video", foreign_key: :author_id

  def self.from_omniauth(auth)
    return nil if [auth.info.name, auth.provider, auth.uid].any? &:blank?

    user = where(provider: auth.provider, uid: auth.uid).first_or_create
    user.email = auth.info.email if auth.info.email
    user.name = auth.info.name
    user.bearer_token = auth.extra.try(:bearer)
    user.save!
    user
  end

end
end

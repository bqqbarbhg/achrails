class User < ActiveRecord::Base
  devise :rememberable, :omniauthable,
    omniauth_providers: [:learning_layers_oidc]

  has_many :memberships
  has_many :groups, through: :memberships, source: :group
  has_many :videos, through: :groups

  has_many :authored_videos, class_name: "Video", foreign_key: :author_id

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      # Remove this when database auth is taken out
      user.password = Devise.friendly_token[0, 20]
    end
  end

  def name
    email.split('@')[0].gsub(/\W+/, ' ').gsub(/[\d_]+/, '').titlecase
  end

end

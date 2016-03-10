class User < ActiveRecord::Base
  devise :rememberable, :omniauthable

  has_many :memberships
  has_many :groups, through: :memberships, source: :group
  has_many :videos, through: :groups
  has_many :sessions

  has_many :authored_videos, class_name: "Video", foreign_key: :author_id

  def self.from_omniauth(auth)
    return nil if [auth.info.name, auth.provider, auth.uid].any? &:blank?

    user = where(provider: auth.provider, uid: auth.uid).first_or_initialize
    user.email = auth.info.email if auth.info.email
    user.name = auth.info.name
    user.bearer_token = auth.extra.try(:bearer)

    user.save!
    user
  end

  def manifest_json
    {
      'id': self.sss_id || '',
      'name': self.name,
      'uri': '',
    }
  end

end

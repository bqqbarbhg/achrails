class User < ActiveRecord::Base
  devise :rememberable, :omniauthable

  before_validation :generate_token
  validates :token, presence: true

  has_many :memberships, dependent: :destroy
  has_many :groups, through: :memberships, source: :group
  has_many :videos, through: :groups
  has_many :sessions, dependent: :destroy

  has_many :authored_videos, class_name: "Video", foreign_key: :author_id

  def self.from_omniauth(auth)
    return nil if [auth.info.name, auth.provider, auth.uid].any? &:blank?

    user = where(provider: auth.provider, uid: auth.uid).first_or_initialize
    user.email = auth.info.email if auth.info.email
    user.preferred_username = auth.info.preferred_username if auth.info.preferred_username
    user.name = auth.info.name
    user.bearer_token = auth.extra.try(:bearer)
    user.refresh_token = auth.extra.try(:refresh)

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

  def generate_token
    self.token ||= loop do
      random_token = SecureRandom.urlsafe_base64(32)
      break random_token unless User.exists?(token: random_token)
    end
  end
end

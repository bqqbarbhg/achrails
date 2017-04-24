class User < ActiveRecord::Base
  include Notifications

  devise :rememberable, :omniauthable

  before_validation :generate_token
  validates :token, presence: true

  has_many :memberships, dependent: :destroy
  has_many :groups, through: :memberships, source: :group
  has_many :videos, through: :groups
  has_many :sessions, dependent: :destroy

  has_many :authored_videos, class_name: "Video", foreign_key: :author_id

  def self.from_omniauth(auth)
    if not auth.info.name or not auth.provider or not auth.uid
      return nil
    end

    if auth.provider == 'learning_layers_oidc'
      auth.info.name = auth.info.name.force_encoding('windows-1252').encode('utf-8')
      auth.info.preferred_username = auth.info.preferred_username.force_encoding('windows-1252').encode('utf-8')
    end

    user = where(provider: auth.provider, uid: auth.uid).first_or_initialize
    user.email = auth.info.try(:email) || user.email
    user.preferred_username = auth.info.try(:preferred_username) || user.preferred_username
    user.name = auth.info.try(:name) || user.name
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

  def create_upload_token
    upload_token ||= loop do
      random_token = SecureRandom.urlsafe_base64(32)
      break random_token unless User.exists?(upload_token: random_token)
    end

    self.update(upload_token: upload_token)
    upload_token
  end

  def generate_token
    self.token ||= loop do
      random_token = SecureRandom.urlsafe_base64(32)
      break random_token unless User.exists?(token: random_token)
    end
  end

  def add_device_token(token)
      if not self.registration_ids.include? token
          self.registration_ids.push(token)
          self.save!
      end
  end

  def remove_device_token(token)
      self.registration_ids.delete(token)
      self.save!
  end

  def notify_user(title, body)
      payload = { notification: { title: title, body: body , icon: "ic_launcher" }}

      response = Notifications.send_notification(self.registration_ids, payload)

      Rails.logger.info "#{response.inspect!}"
  end
end

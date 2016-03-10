class Session < ActiveRecord::Base

  before_validation :generate_token
  validates :token, presence: true

  belongs_to :user

  def generate_token
    self.token ||= loop do
      random_token = SecureRandom.urlsafe_base64(32)
      break random_token unless Session.exists?(token: random_token)
    end
  end
end


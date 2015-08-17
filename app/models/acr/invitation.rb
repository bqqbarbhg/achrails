unless SSS
class Invitation < ActiveRecord::Base

  before_validation :generate_token

  belongs_to :group

  validates :token, presence: true

  def to_param
    token
  end

  def can_join?(user)
    expect_email == user.email
  end

protected
  def generate_token
    self.token ||= loop do
      random_token = SecureRandom.urlsafe_base64(32)
      break random_token unless Invitation.exists?(token: random_token)
    end
  end
end
end

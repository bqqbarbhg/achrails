class Session < ActiveRecord::Base

  belongs_to :user

  def self.create_code_auth(opts)
    code = SecureRandom.urlsafe_base64(16)
    ttl = 10.minutes.from_now
    Session.create!(opts.merge(code: code, expires_at: ttl))
  end

  def activate!
    access_token = SecureRandom.urlsafe_base64(16)
    refresh_token = SecureRandom.urlsafe_base64(64)
    ttl = 2.hours.from_now
    update!(code: nil, access_token: access_token, refresh_token: refresh_token, expires_at: ttl)
  end

  def refresh!
    activate!
  end

  def expires_in
    expires_at - Time.now
  end

  def expired?
    Time.now > expires_at
  end

end


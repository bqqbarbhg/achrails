
Warden::Strategies.add(:upload_token_authentication) do
  def valid?
    upload_token.present?
  end

  def authenticate!
    user = User.find_by_upload_token(upload_token)
    if user
      success!(user) 
    else
      fail
    end
  end

protected
  def upload_token
    @upload_token ||= request.headers['X-Upload-Token']      
  end
end


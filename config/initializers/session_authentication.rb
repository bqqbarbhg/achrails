
Warden::Strategies.add(:session_authentication) do
  def valid?
    session_token.present?
  end

  def authenticate!
    session = Session.find_by_access_token(session_token)
    if session
      success!(session.user) 
    else
      fail
    end
  end

protected

  def authorization
    request.authorization
  end

  def session_token
    @session_token ||= begin
      auth = authorization
      if auth
        tokens = auth.split(/\s+/, 2)
        tokens[1] if tokens.length == 2 && tokens[0].downcase == 'bearer'
      end
    end
  end
end


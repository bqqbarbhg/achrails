
Warden::Strategies.add(:session_authentication) do
  def valid?
    session_token
  end

  def authenticate!
    session = Session.find_by_token(session_token)
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
        tokens[1] if tokens.length == 2 && tokens[0].downcase == 'session'
      end
    end
  end
end


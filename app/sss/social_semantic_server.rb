class SocialSemanticServer

  def log(message)
    Rails.logger.debug("@SSS: #{message}")
  end

  def logcall(message)
    Rails.logger.debug("@SSS-CALL: #{message}")
  end

  def initialize(url, bearer)
    @users = { }
    @videos = { }
    @groups = { }

    uri = URI(url)

    @root = uri.path
    @conn = Faraday.new("#{uri.scheme}://#{uri.host}",
      headers: {
        "Authorization" => "Bearer #{bearer}",
        "Accept" => "application/json",
      })
  end

  def validate_response(response)
    if response.status >= 400
      body_json = JSON.parse(response.body)
      if body_json && body_json["id"] == "authOIDCUserInfoRequestFailed"
        log "Authentication failed"
        raise SssConnectError
      else
        log "Response error with status #{response.status}"
        raise SssInternalError, response.body
      end
    end
    response
  rescue JSON::ParserError
    log "Response error with status #{response.status}"
    raise SssInternalError, response.body
  end

  def get(path)
    logcall "GET #{path}"
    validate_response @conn.get(@root + path)
  end

  def get_json(path)
    response = get(path)
    data = JSON.parse(response.body)
    data.deep_symbolize_keys! if data
  end

  def post(path, content_type, body)
    logcall "POST #{path} #{body}"
    validate_response @conn.post(@root + path, body,
      'Content-Type' => content_type)
  end

  def post_json(path, json)
    response = post(path, 'application/json', json.to_json)
    data = JSON.parse(response.body)
    data.deep_symbolize_keys! if data
  end

  def delete(path)
    logcall "DELETE #{path}"
    validate_response @conn.delete(@root + path)
  end

  def delete_json(path, body)
    logcall "DELETE #{path} #{body}"
    response = @conn.run_request(:delete, @root + path, body.to_json,
      'Content-Type' => 'application/json')
    data = JSON.parse(response.body)
    data.deep_symbolize_keys! if data
  end

  def isolate_uuid(str)
    str[/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/] if str
  end

  def isolate_id(str)
    str[/\d+/] if str
  end

  def to_person(user_hash)
    id = isolate_id(user_hash[:id])
    return nil unless id
    @users[id] ||= Person.new(
      id: id,
      email: user_hash[:email],
      name: nil,
    )
  end

  def to_group(circle_hash)
    id = isolate_id(circle_hash[:id])
    return nil unless id
    @groups[id] ||= begin
      group = Group.new(
        id: id,
        name: circle_hash[:label],
        description: circle_hash[:description]
      )

      author_id = circle_hash[:author][:id]
      group.memberships = circle_hash[:users].map do |user|
        Membership.new(
          group: group,
          user: full_person(user),
          admin?: user[:id] == author_id,
        )
      end

      group.videos = circle_hash[:entities]
        .select { |entity| entity[:type] == "video" }
        .map { |video| to_video(video) }
        .reject(&:nil?)
        .select(&:hosted?)

      group
    end
  end

  def to_video(video_hash)
    id = isolate_uuid(video_hash[:id])
    return nil unless id
    @videos[id] ||= Video.new(
      uuid: id,
      title: video_hash[:label],
      author: full_person(video_hash[:author]),
    )
  end

  def groups
    @groups_cached ||= begin
      data = get_json('/circles/circles')
      circles = data[:circles]

      circles.map { |circle| to_group(circle) }.reject &:nil?
    end
  end

  def group(id)
    groups.select { |group| group.id == id }.first
  end

  def group_add_videos(group, videos)
    ids = videos.map(&:uuid).join(',')
    post_json("/circles/circles/#{group.id}/entities/#{ids}/", { })
  end

  def group_remove_videos(group, videos)
    ids = videos.map(&:uuid).join(',')
    delete_json("/circles/circles/#{group.id}/entities/#{ids}/", { })
  end

  def create_group(params)
    hash = post_json '/circles/circles/',
      label: params[:name],
      description: params[:description] || ''

    isolate_id(hash[:circle])
  end

  def delete_group(group)
    id = group.id
    delete("/circles/circles/#{id}")
  end

  def groups_for(user)
    groups.select { |group| group.member?(user) }
  end

  def join_group(group_id, user)
    hash = post_json("/circles/circles/#{group_id}/users/#{user.person_id}", { })
  end

  def invite_to_group(group, emails)
    emails_s = emails.join(',')
    hash = post_json("/circles/circles/#{group.id}/users/invite/#{emails_s}", { })
  end

  def people
    @people_cached ||= begin
      data = get_json('/users/users')
      users = data[:users]

      people_arr = users.map { |user| to_person(user) }.reject &:nil?
      people_map = people_arr.map { |person| [person.id, person] }.to_h
      emails = people_arr.map &:email
      users = User.where(email: emails)
      users.each do |user|
        people_map[user.person_id].name = user.name if people_map[user.person_id]
      end

      people_map
    end
  end

  def person(id)
    people[id]
  end

  def full_person(partial_user_hash)
    id = isolate_id(partial_user_hash[:id])
    person(id)
  end

  def auth_person
    @auth_person_cached ||= begin
      data = get_json('/auth/auth')
      user_id = isolate_id(data[:user])
      person(user_id)
    end
  end

  def videos
    @videos_cached ||= begin
      data = get_json('/videos/videos')
      videos = data[:videos]

      videos
        .map { |video| to_video(video) }
        .reject(&:nil?)
        .select(&:hosted?)
    end
  end

  def video(uuid)
    videos.select { |video| video.uuid == uuid }.first
  end

  def create_video(video)
    post_json '/videos/videos',
      uuid: video.uuid,
      link: Rails.application.routes.url_helpers.video_url(video),
      label: video.title
  end

end

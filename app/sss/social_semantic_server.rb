class SocialSemanticServer

  def log(message)
    Rails.logger.debug("@SSS: as #{@sss_id}: #{message}")
  end

  def logcall(message)
    Rails.logger.debug("@SSS-CALL: as #{@sss_id}: #{message}")
  end

  def initialize(url, bearer, sss_id)
    @users = { }
    @videos = { }
    @groups = { }
    @sss_id = sss_id

    uri = URI(url)

    @root = uri.path
    @conn = Faraday.new("#{uri.scheme}://#{uri.host}",
      headers: {
        "Authorization" => "Bearer #{bearer}",
        "Accept" => "application/json",
      })
  end

  def validate_response(response)
    Rails.logger.debug("@SSS-CALL: #{response.status} #{response.body.truncate(200)}")
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
    response = validate_response @conn.run_request(:delete, @root + path, body.to_json,
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

  def group_add_videos(group, videos)
    circle_id = group.sss_id

    raise SssInternalError, "Trying to add videos to non-SSS group #{group.id}" unless circle_id

    video_ids = videos.pluck(:uuid).join(',')
    post_json("/circles/circles/#{circle_id}/entities/#{video_ids}/", { })
    log "Added #{video_ids} to circle #{circle_id}"
  end

  def group_remove_videos(group, videos)
    circle_id = group.sss_id

    log "Trying to remove videos to non-SSS group #{group.id}" and return unless circle_id

    video_ids = videos.pluck(:uuid).join(',')
    delete_json("/circles/circles/#{circle_id}/entities/#{video_ids}/", { })
    log "Removed #{video_ids} from circle #{circle_id}"
  end

  def create_group(group)

    hash = post_json '/circles/circles/',
      label: group.name,
      description: group.description

    id = isolate_id(hash[:circle])
    log "Created circle #{id} for group #{group.id}"

    group.sss_id = id
  end

  def destroy_group(group)
    circle_id = group.sss_id
    log "Deleted group that is not in sss #{group.id}" and return unless circle_id

    delete("/circles/circles/#{circle_id}")
    log "Deleted circle #{circle_id} for group #{group.id}"
  end

  def join_group(group, user)
    circle_id = group.sss_id
    user_id = user.sss_id

    raise SssInternalError, "Trying to join non-SSS group #{group.id}" if not circle_id
    raise SssInternalError, "Trying to join non-SSS user #{user.id}" if not user_id

    hash = post_json("/circles/circles/#{circle_id}/users/#{user_id}", { })
    log "Joined user #{user_id} to circle #{circle_id}"
  end

  def leave_group(group, user)
    circle_id = group.sss_id
    user_id = user.sss_id

    log "Trying to leave non-SSS group #{group.id}" and return unless circle_id
    log "Trying to leave non-SSS user #{user.id}" and return unless user_id

    hash = delete_json("/circles/circles/#{group.id}/users/#{user.sss_id}", { })
    log "Removed user #{user.sss_id} from group #{group.id}"
  end

  def invite_to_group(group, emails)
    circle_id = group.sss_id

    raise SssInternalError, "Trying to invite to non-SSS group #{group.id}" if not circle_id

    emails_s = emails.join(',')
    hash = post_json("/circles/circles/#{circle_id}/users/invite/#{emails_s}", { })
    log "Invited #{emails_s} to circle #{circle_id}"
  end

  def current_user_sss_id
    data = get_json('/auth/auth')
    user_id = isolate_id(data[:user])
    log "Retrieved user ID: #{user_id}"
    user_id
  end

  def create_video(video)
    post_json '/videos/videos',
      uuid: video.uuid,
      link: Rails.application.routes.url_helpers.video_url(video),
      label: video.title
    log "Uploaded video #{video.uuid}"
  end

end

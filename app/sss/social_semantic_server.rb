class SocialSemanticServer

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

  def get(path)
    @conn.get(@root + path)
  end

  def get_json(path)
    response = get(path)
    data = JSON.parse(response.body)
    data.deep_symbolize_keys! if data
  end

  def isolate_uuid(str)
    str[/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/]
  end

  def isolate_id(str)
    str[/\d+/]
  end

  def to_person(user_hash)
    id = isolate_id(user_hash[:id])
    @users[id] ||= Person.new(
      id: id,
      name: user_hash[:label],
    )
  end

  def to_group(circle_hash)
    id = isolate_id(circle_hash[:id])
    @groups[id] ||= begin
      group = Group.new(
        id: id,
        name: circle_hash[:label]
      )

      author_id = circle_hash[:author][:id]
      group.memberships = circle_hash[:users].map do |user|
        Membership.new(
          group: group,
          user: to_person(user),
          admin?: user[:id] == author_id,
        )
      end

      group.videos = circle_hash[:entities]
        .select { |entity| entity[:type] == "video" }
        .map { |video| to_video(video) }

      group
    end
  end

  def to_video(video_hash)
    id = isolate_uuid(video_hash[:id])
    @videos[id] ||= Video.new(
      uuid: id,
      title: video_hash[:label],
      author: to_person(video_hash[:author]),
    )
  end

  def groups
    data = get_json('/circles/circles')
    circles = data[:circles]

    circles.map { |circle| to_group(circle) }
  end

  def group(id)
    groups.select { |group| group.id == id }.first
  end

  def people
    data = get_json('/users/users')
    users = data[:users]

    users.map { |user| to_person(user) }
  end

  def person(id)
    people.select { |person| person.id == id }.first
  end

  def auth_person
    data = get_json('/auth/auth')
    user_id = isolate_id(data[:user])
    person(user_id)
  end

  def videos

  end

end

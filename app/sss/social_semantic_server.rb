module SSS
  class SocialSemanticServer

    def initialize(url, bearer)
      @users = { }
      @videos = { }

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

    def isolate_uuid(str)
      str[/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/]
    end

    def isolate_id(str)
      str[/\d+/]
    end

    def to_user(user_hash)
      @users[user_hash[:id]] ||= User.new(
        name: user_hash[:label],
      )
    end

    def to_video(video_hash)
      id = isolate_uuid(video_hash[:id])
      @videos[id] ||= Video.new(
        uuid: id,
        title: video_hash[:label],
        author: to_user(video_hash[:author]),
      )
    end

    def groups
      data = get('/circles/circles')
      data.deep_symbolize_keys!
      circles = data[:circles]

      circles.map do |circle|
        group = Group.new( name: circle[:label] )
        author_id = circle[:author][:id]

        group.memberships = circle[:users].map do |user|
          Membership.new(
            group: group,
            user: to_user(user),
            admin?: user[:id] == author_id,
          )
        end

        group.videos = circle[:entities]
          .select { |entity| entity[:type] == "video" }
          .map { |video| to_video(video) }

        group
      end
    end
    def group(id)
      groups.select { |group| group.id == id }.first
    end
  end
end


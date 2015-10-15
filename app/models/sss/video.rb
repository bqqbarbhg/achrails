if SSS
class Video < Struct.new(:uuid, :title, :author, :groups)
  include ActiveModel::Model
  def initialize(hash)
    hash.each { |key, value| self[key] = value }
  end
  def persisted?
    true
  end

  def self.from_manifest(manifest, user)
    json = JSON.parse(manifest)
    uuid = json["id"]
    video_manifest = VideoManifest.where(uuid: uuid).first_or_initialize
    video_manifest.update_revision!
    video_manifest.manifest_json = json
    video_manifest.searchable = Util.manifest_to_searchable(json)
    video_manifest.video_url = Util.normalize_url(json["videoUri"])
    video_manifest.save!

    video = Video.new(
      title: json["title"],
      uuid: uuid)
    video.set_manifest!(video_manifest)
    video
  end

  def hosted?
    VideoManifest.exists?(uuid: uuid)
  end

  def manifest
    @manifest ||= VideoManifest.where(uuid: uuid).first
  end

  def read_manifest
    manifest.read_manifest
  end

  def last_modified
    manifest.updated_at
  end

  def revision
    manifest.revision
  end

  def to_param
    uuid
  end

  def author?(user)
    author.id == user.person_id
  end

  def set_manifest!(m)
    @manifest = m
  end

end
end

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
    video_manifest = VideoManifest.first_or_initialize(uuid: uuid)
    video_manifest.manifest_json = json
    video_manifest.save!

    Video.new(
      title: json["title"],
      uuid: uuid)
  end

  def hosted?
    VideoManifest.exists?(uuid: uuid)
  end

  def read_manifest
    VideoManifest.where(uuid: uuid).first.read_manifest
  end

  def last_modified
    VideoManifest.where(uuid: uuid).first.updated_at
  end

  def to_param
    uuid
  end

  def author?(user)
    author.id == user.person_id
  end
end
end

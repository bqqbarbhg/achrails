if SSS
class Video < Struct.new(:uuid, :title, :author, :groups)
  include ActiveModel::Model
  def initialize(hash)
    hash.each { |key, value| self[key] = value }
  end
  def persisted?
    true
  end

  def self.from_manifest(manifest)
    json = JSON.parse(manifest)
    uuid = json["id"]
    VideoManifest.first_or_create(uuid: uuid).update(manifest_json: json)
    Video.new(
      title: json["title"],
      uuid: uuid)
  end

  def read_manifest
    VideoManifest.where(uuid: uuid).first.read_manifest
  end

  def to_param
    uuid
  end

  def author?(user)
    author.id == user.person_id
  end
end
end

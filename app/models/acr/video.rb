unless SSS
class Video < ActiveRecord::Base

  belongs_to :author, class_name: "User"
  has_and_belongs_to_many :groups, uniq: true

  validates :title, presence: true
  validates :uuid, presence: true

  def self.from_manifest(manifest)
    json = JSON.parse(manifest)
    Video.create(
      title: json["title"],
      uuid: json["uuid"],
      author: current_user,
      manifest_json: json)
  end

  def read_manifest
    manifest_json
  end

  def to_param
    uuid
  end

  def author?(user)
    author == user
  end
end
end

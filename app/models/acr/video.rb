unless SSS
class Video < ActiveRecord::Base

  include PgSearch

  pg_search_scope :search, against: :searchable

  belongs_to :author, class_name: "User"
  has_and_belongs_to_many :groups, uniq: true

  validates :title, presence: true
  validates :uuid, presence: true

  def self.from_manifest(manifest, user)
    json = JSON.parse(manifest)
    Video.create!(
      title: json["title"],
      uuid: json["id"],
      author: user,
      manifest_json: json,
      searchable: Util.manifest_to_searchable(json),
      video_url: Util.normalize_url(json["videoUri"]))
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

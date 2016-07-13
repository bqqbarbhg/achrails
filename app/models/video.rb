class Video < ActiveRecord::Base

  default_scope { where(deleted_at: nil) }

  include PgSearch

  pg_search_scope :search, against: :searchable

  belongs_to :author, class_name: "User"
  has_and_belongs_to_many :groups, uniq: true
  has_many :video_revision_blocks

  validates :title, presence: true
  validates :uuid, presence: true

  def revisions_in(range)
    video_revision_blocks
      .where('first_num <= ? and last_num >= ?', range.end, range.begin)
      .order('last_num desc')
      .all.map(&:revisions)
      .flatten(1)
      .select { |v| range.cover?(v["revision"]) }
  end

  def manifest_revision(num)
    revisions_in(num..num).first
  end

  def all_revisions
    revisions_in(1..revision_num)
  end

  def soft_destroy
    self.deleted_at = Time.now
    self.save!
  end

  def import_manifest_data(manifest)
    self.manifest_json = manifest
    self.title = manifest["title"]
    self.uuid = manifest["id"]
    self.searchable = Util.manifest_to_searchable(manifest)
    self.video_url = Util.normalize_url(manifest["videoUri"])
  end

  def update_manifest(manifest)
    new_revision_num = revision_num + 1
    manifest["revision"] = new_revision_num

    rev_block = video_revision_blocks.where(last_num: revision_num).first
    if rev_block.nil? or rev_block.revision_count > 20
      rev_block = video_revision_blocks.new(first_num: new_revision_num,
                                            last_num: new_revision_num)
      rev_block.revisions = [manifest]
    else
      rev_block.revisions = rev_block.revisions.unshift(manifest)
      rev_block.last_num = new_revision_num
    end

    self.revision_num = new_revision_num
    self.import_manifest_data(manifest)

    transaction do
      self.save!
      rev_block.save!
    end
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

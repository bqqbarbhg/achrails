class Video < ActiveRecord::Base

  has_attached_file :manifest

  belongs_to :author, class_name: "User"
  has_and_belongs_to_many :groups, uniq: true

  validates :title, presence: true
  validates :uuid, presence: true

  validates_attachment :manifest, presence: true,
      size: { in: 0..10.kilobytes }
  do_not_validate_attachment_file_type :manifest

  def group_id_list
    groups.select(:id).map{|u| u.id.to_s }
  end

  def read_manifest
      Paperclip.io_adapters.for(manifest).read 
  end

end

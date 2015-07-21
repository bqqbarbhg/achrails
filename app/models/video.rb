class Video < ActiveRecord::Base

  belongs_to :author, class_name: "User"
  has_and_belongs_to_many :groups, uniq: true

  validates :title, presence: true
  validates :uuid, presence: true

  def group_id_list
    groups.select(:id).map{|u| u.id.to_s }
  end

  def read_manifest
      manifest_json
  end

  def to_param
    uuid
  end

end

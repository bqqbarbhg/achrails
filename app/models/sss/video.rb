if SSS
class Video < Struct.new(:uuid, :title, :author, :groups)
  include ActiveModel::Model
  def initialize(hash)
    hash.each { |key, value| self[key] = value }
  end
  def persisted?
    true
  end

  def group_id_list
    groups.map &:id
  end

  def read_manifest
      manifest_json
  end

  def to_param
    uuid
  end
end
end

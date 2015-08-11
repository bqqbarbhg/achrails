if SSS
class VideoManifest < ActiveRecord::Base

  def read_manifest
    manifest_json
  end

  def to_param
    uuid
  end
end
end

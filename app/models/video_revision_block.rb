class VideoRevisionBlock < ActiveRecord::Base
  belongs_to :video

  validates :first_num, presence: true
  validates :last_num, presence: true

  def revision_count
    last_num - first_num + 1
  end

  def revisions
    if compressed_revisions
      JSON.parse(Zlib.inflate(compressed_revisions))
    else
      []
    end
  rescue JSON::ParseError
    []
  end

  def revisions=(value)
    self.compressed_revisions = Zlib.deflate(value.to_json)
    value
  end

end

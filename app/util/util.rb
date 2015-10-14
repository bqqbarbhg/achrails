module Util
  def self.normalize_url(url)
    url.gsub(/https?:\/\//, '')
  end
end


module Util
  def self.normalize_url(url)
    url.gsub(/https?:\/\//, '')
  end

  def self.manifest_to_searchable(manifest)
    title = manifest["title"]
    annotation_texts = manifest["annotations"].map do |annotation|
      annotation["text"] or ''
    end

    ([title] + annotation_texts).join(' ')
  end
end


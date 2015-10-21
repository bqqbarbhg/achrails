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

  def self.manifest_diff(old, new)
    old_as = (old["annotations"] || []).sort_by { |a| a["time"] }
    new_as = (new["annotations"] || []).sort_by { |a| a["time"] }

    ops = []

    new_as.each do |ann|
      existing_i = old_as.index(ann)
      old_as.slice!(existing_i) and next if not existing_i.nil?

      moved_i = old_as.index { |a| a["time"] == ann["time"] && a["text"].present? && a["text"] == ann["text"] }
      if moved_i
        ops << { op: :move, time: ann["time"] / 1000.0, dst: ann, src: old_as.slice!(moved_i) }
        next
      end

      text_i = old_as.index { |a| a["time"] == ann["time"] && a["position"] == ann["position"] }
      if text_i
        ops << { op: :text, time: ann["time"] / 1000.0, dst: ann, src: old_as.slice!(text_i) }
        next
      end

      ops << { op: :new, time: ann["time"] / 1000.0, dst: ann }
    end

    ops += old_as.map { |ann| { op: :delete, time: ann["time"] / 1000.0, src: ann } }

    ops
  end
end


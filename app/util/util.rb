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

  def normalize_manifest!(manifest)
    manifest["annotations"].sort_by! do |a|
      [a["time"], a["position"]["x"], a["position"]["y"], a["text"],
       a["user"]["id"], a["user"]["uri"], a["user"]["name"]]
    end
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

  def self.split_manifest(manifest)
    fields = manifest.clone
    annotations = fields.delete("annotations").to_set

    [fields, annotations]
  end

  def self.merge_manifests(a, b, old)

    # Split the manifests into fields and annotations
    a_fields, a_annotations = split_manifest(a)
    b_fields, b_annotations = split_manifest(b)
    old_fields, old_annotations = split_manifest(old)

    merged = { }
    lost_data = false

    # Prefer B in case no way to resolve conflict
    dealbreaker_fields = b_fields

    # For every value that exists in both manifests select the one that differs
    # from the common ancestor if possible.
    common_keys = a_fields.keys & b_fields.keys
    common_keys.each do |key|
      merged[key] = if a_fields[key] == old_fields[key]
        b_fields[key] # A value is the same as old, thus B only was modified
      elsif b_fields[key] == old_fields[key]
        a_fields[key] # B value is the same as old, thus A only was modified
      else
        lost_data = true
        dealbreaker_fields[key] # Both were modified, just take one
      end
    end

    # For values in only one of the manifests take that.
    [a_fields, b_fields].each do |fields|
      fields.except(*common_keys).each do |key, val|
        merged[key] = val
      end
    end

    merged_annotations = []

    # Add all annotations that are present in both versions.
    shared_annotations = a_annotations & b_annotations
    merged_annotations += shared_annotations.to_a

    # Go through the distinct annotations
    distinct_annotations = a_annotations ^ b_annotations
    distinct_annotations.each do |annotation|

      # If the annotation exists only in one manifest and the common ancestor
      # it was deleted from the other one, so don't include it in the merged
      next if old_annotations.include?(annotation)

      # A new annotation exists in one of the versions. There is no way to
      # tell the difference between a modified and a created annotation at the
      # moment so this might duplicate annotations fo now, but no work is lost.
      merged_annotations << annotation
    end

    merged["annotations"] = merged_annotations

    {
      manifest: merged,
      lost_data: lost_data
    }
  end
end


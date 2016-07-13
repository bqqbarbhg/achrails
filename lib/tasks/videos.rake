namespace :videos do
  desc "Normalizes all video manifests"
  task :normalize => :environment do

    num = 0

    puts "Normalizing video manifests"

    Video.all.each do |video|
      manifest = video.read_manifest
      new_manifest = manifest.deep_dup
      Util.normalize_manifest!(new_manifest)
      if manifest != new_manifest
        puts "Normalized manifest for: #{video.uuid}"
        num += 1
        video.update_manifest(new_manifest)
      end
    end

    puts "Normalized #{num} manifests"

  end

  desc "Updates video search metadata"
  task :update_search => :environment do

    num = 0

    puts "Updating video searching metadata"

    Video.all.each do |video|
      video.searchable = Util.manifest_to_searchable(video.manifest_json)
      video.save!
      num += 1
    end

    puts "Updated #{num} videos to searchable"

  end

  desc "Permanently removes soft deleted videos"
  task :delete_permanently => :environment do

    num = 0

    puts "Permanently deleting videos"

    Video.unscoped.where.not(:deleted_at => nil).each do | video |
      num += 1
    end

    puts "Deleted #{num} videos permanently"

  end
end

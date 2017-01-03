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
  task :delete_permanently, [:arg1 ] => :environment do | t, args |

    args.with_defaults(:arg1 => (Time.now - 3.weeks).to_s)

    older_than = DateTime.parse(args[:arg1])

    num = 0

    puts "Permanently deleting videos"

    Video.unscoped.where("deleted_at < ?", older_than).each do | video |
      num += 1

      # Delete the video data
      manifest = video.read_manifest
      deleteUrl = manifest["deleteUri"]

      if deleteUrl.present?
        begin
          response = Faraday.delete(deleteUrl) do |req|
            req.headers['Delete-Authorization'] = ENV['GOTR_DELETE_SECRET']
          end
          puts "DELETE #{deleteUrl} -> #{response.status}"
        rescue SocketError => e
          puts e.message
        end
      end

      video.destroy
    end

    puts "Deleted #{num} videos permanently"

  end
end

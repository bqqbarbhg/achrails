namespace :events do
  desc "Dumps all log data"
  task :dump => :environment do

    lines = LogEvent.all.order(:created_at).map(&:to_line)
    puts lines.join("\n")

  end

  desc "Dumps mapping between IDs and names"
  task :names => :environment do
    puts JSON.generate({
      users: User.all.pluck(:id, :name).to_h,
      groups: Group.all.pluck(:id, :name).to_h,
      videos: Video.all.pluck(:id, :title).to_h,
    })
  end

  desc "Permanently removes log events older than specified timestamp"
  task :delete_permanently, [:arg1 ] => :environment do | t, args |

    args.with_defaults(:arg1 => (Time.now - 3.weeks).to_s)

    older_than = DateTime.parse(args[:arg1])

    num = 0

    puts "Deleting log events..."

    LogEvent.where("created_at < ?", older_than).each do | log |
      num += 1
      log.destroy
    end

    puts "Deleted #{num} logs"
  end
end


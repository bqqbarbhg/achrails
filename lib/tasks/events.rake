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
end


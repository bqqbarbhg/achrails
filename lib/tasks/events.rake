namespace :events do
  desc "Dumps all log data"
  task :dump => :environment do

    lines = LogEvent.all.map(&:to_line)
    puts lines.join("\n")

  end
end


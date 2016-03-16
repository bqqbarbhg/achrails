
set :output, 'log/cron.log'

every 1.hours do
  rake 'sessions:purge'
end


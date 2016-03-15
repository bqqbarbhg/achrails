namespace :sessions do
  desc "Restricts the number of sessions that any one user can have"
  task :purge => :environment do

    max_sessions_per_user = 10

    puts "Purging sessions..."
    num_sessions_start = Session.count
    puts "Sessions: #{num_sessions_start}"

    num_sessions = num_sessions_start

    num_code_expired = Session.where('expires_at < ?',  Time.now).includes(:code).delete_all
    num_sessions -= num_code_expired
    if num_code_expired > 0
      puts "Sessions: #{num_sessions} (Deleted #{num_code_expired} expired code requests)"
    end

    sessions = Session.where('expires_at < ?', Time.now - 1.days).group(:user_id).count.select { |u, c| (c || 0) > max_sessions_per_user }
    sessions.each do |user_id, sessions|
      user = User.find_by_id(user_id)
      next unless user

      ids = user.sessions.where('expires_at < ?', Time.now - 1.days).order(:expires_at).limit(sessions - max_sessions_per_user).pluck(:id)
      num_deleted = Session.delete_all(id: ids)

      num_sessions -= num_deleted
      puts "Sessions: #{num_sessions} (Deleted #{num_deleted} from user #{user_id})"
    end

    puts "Sessions: #{num_sessions} (Deleted #{num_sessions_start - num_sessions} in total)"
    puts "Done."
  end
end

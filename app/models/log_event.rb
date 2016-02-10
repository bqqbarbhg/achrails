class LogEvent < ActiveRecord::Base

  enum event_type: [
    :create_group,
    :delete_group,
    :join_group,
    :leave_group,

    :upload_video,
    :delete_video,
    :view_video,
    :edit_video,
    :share_video,
  ]

  validates :user, presence: true
  validates :event_type, presence: true
  validates :event_target, presence: true

  def self.log(user, type, target)
    return unless user.present?

    LogEvent.create!(user: user.id, event_type: type, event_target: target.id)
  end

  def to_line
    "#{event_type} #{user} #{event_target}"
  end

end


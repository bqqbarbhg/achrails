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
    :share_video, # extra: group, state: is shared?
    :publish_video, # state: is public?
  ]

  validates :user, presence: true
  validates :event_type, presence: true
  validates :event_target, presence: true

  def self.log(user, type, target, extra, state)
    return unless user.present?

    unless state.nil?
      previous = LogEvent.where(event_type: self.event_types[type], event_target: target.id, extra: extra).order(:id).last
      if previous.present? && previous.user == user.id && previous.created_at >= Time.now - 1.hours
        previous.update(state: state)
        return previous
      end
    end

    LogEvent.create!(user: user.id, event_type: type, event_target: target.id, extra: extra, state: state)
  end

  def to_line
    "#{created_at},#{event_type},#{user},#{event_target},#{extra},#{state}"
  end

end


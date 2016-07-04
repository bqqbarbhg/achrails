class Webhook < ActiveRecord::Base
  belongs_to :group

  def self.event_types
    %w(video_edit video_view new_video)
  end

  def self.validate_event_type(event)
    event_types.include? event
  end
end

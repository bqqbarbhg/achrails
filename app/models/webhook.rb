require 'uri'

class Webhook < ActiveRecord::Base
  belongs_to :group
  validates :notification_url, presence: true
  validates :notification_url, format: { with: URI.regexp }, if: 'notification_url.present?'

  def self.event_types
    %w(video_edit video_view new_video)
  end

  def self.validate_event_type(event)
    event_types.include? event
  end

  def self.validate_url(url)
    !!URI.parse(url)
  rescue URI::InvalidUriError
    false
  end
end

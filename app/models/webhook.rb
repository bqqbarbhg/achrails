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

  def call_self(data)
    if data.key?(:user)
      data[:user] = data[:user].as_json(only: [:email, :preferred_username, :name])
    end

    response = Faraday.post(self.notification_url) do |req|
      req.headers['Content-Type'] = 'application/json'
      req.body = data.to_json
    end

    Rails.logger.debug "POST #{self.notification_url} -> #{response.status}"
    Rails.logger.debug "DATA: #{data.to_json}"
  end

  def format_payload(video, user)
    return { uuid: video.uuid, video_player: video.get_player_url, video_title: video.title, video_uri: video.video_url, thumb_uri: video.manifest_json["thumbUri"], user: user  }

  end

  def notify_new_video(video, user)
    payload = format_payload(video, user)
    payload[:event_type] = 'new_video'
    call_self(payload)
  end

  def notify_video_edit(video, user)
    payload = format_payload(video, user)
    payload[:event_type] = 'video_edit'
    call_self(payload)
  end

  def notify_video_view(video, user)
    payload = format_payload(video, user)
    payload[:event_type] = 'video_view'
    call_self(payload)
  end
end

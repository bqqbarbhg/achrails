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

  def notify_new_video(video, user)
    call_self({ uuid: video.uuid, video_title: video.title, video_uri: video.video_url, event_type: 'new_video', user: user })
  end

  def notify_video_edit(video, user)
    call_self({ uuid: video.uuid, video_title: video.title, video_uri: video.video_url, event_type: 'video_edit', user: user })
  end

  def notify_video_view(video, user)
    call_self({ uuid: video.uuid, video_title: video.title, video_uri: video.video_url, event_type: 'video_view', user: user })
  end
end

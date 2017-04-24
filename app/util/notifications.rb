module Notifications
    def self.client
        @fcm ||= FCM.new(ENV["FIREBASE_API_KEY"])
    end

    def self.send_notification(ids, data)
        c = client

        return c.send(ids, data)
    end
end

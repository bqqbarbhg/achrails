module Notifications
    def self.client
        @fcm ||= FCM.new(ENV["FIREBASE_API_KEY"])
    end

    def self.send_notification(ids, data)
        c = client

        return c.send(ids, data)
    end

    def self.create_notification_key(key_name, registration_id)
        c = client

        return c.create(key_name, ENV["FIREBASE_PROJECT_ID"], [registration_id])
    end

    def self.add_registration_token(key_name, notification_key, registration_id)
        c = client

        return c.add(key_name,
                        ENV["FIREBASE_PROJECT_ID"],
                        notification_key,
                        [registration_id])

    end

    def self.remove_registration_token(key_name, notification_key, registration_id)
        c = client

        return c.remove(key_name,
                        ENV["FIREBASE_PROJECT_ID"],
                        notification_key,
                        [registration_id])
    end
end

fcm = FCM.new(ENV["FIREBASE_API_KEY"])

module Notifications
    def send_notification(token, data, collapse_key)
        return fcm.send_with_notification_key(token,
                                            data:  data,
                                            collapse_key: collapse_key)
    end

    def create_notification_key(key_name, registration_id)
        return fcm.create(key_name: key_name,
                          project_id: ENV["FIREBASE_PROJECT_ID"],
                          registrationd_ids: [registration_id])
    end

    def add_registration_token(key_name, notification_key, registration_id)
        return fmc.add(key_name:key_name,
                        project_id: ENV["FIREBASE_PROJECT_ID"],
                        notification_key: notification_key,
                        registration_ids: [registration_id])

    end

    def remove_registration_token(key_name, notification_key, registration_id)
        return fmc.remove(key_name:key_name,
                        project_id: ENV["FIREBASE_PROJECT_ID"],
                        notification_key: notification_key,
                        registration_ids: [registration_id])
    end
end

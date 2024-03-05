module Core
  class GlobalNotifications

    def self.has_notifications?
      notifications = load_notifications
      # #present? is also a Rails method. It does the opposite of what #blank? does.
      notifications.present?
    end

    def self.load_notifications
      begin
        JSON.parse(File.read(File.join(Rails.root, "config", "global_notifications.json")))
      rescue
        []
      end
    end

  end
end
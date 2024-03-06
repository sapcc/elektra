require 'filewatcher'

class GlobalNotificationsController < ActionController::Base
  # Path to the file: elektra/config/global_notifications/messages.yaml
  GLOBAL_NOTIFICATIONS_FILE_PATH = Rails.root.join('config', 'global_notifications', 'messages.yaml') 
   
  # class variable to hold the notifications
  @@notifications = []
  
  # FileUpdateChecker to watch for changes in the file
  @@file_reloader = ActiveSupport::FileUpdateChecker.new([GLOBAL_NOTIFICATIONS_FILE_PATH]) do
    begin 
      @@notifications = YAML.load(File.read(GLOBAL_NOTIFICATIONS_FILE_PATH)).to_json
    rescue => e
      pp e
      # In case of any error, set the notifications to empty array
      []
    end
  end
  # execute the file reloader initially
  @@file_reloader.execute

  def self.global_notifications 
    # execute the file reloader if the file is updated
    @@file_reloader.execute_if_updated
    # return the notifications
    @@notifications
  end
  
  def index    
    render json: self.class.global_notifications
  end
end
require 'filewatcher'

class GlobalNotificationsController < ActionController::Base

  GLOBAL_NOTIFICATIONS_FILE_PATH = Rails.root.join('config', 'global_notifications', 'messages.yaml') 
  @@notifications = nil


  # file_reloader = ActiveSupport::FileUpdateChecker.new([GLOBAL_NOTIFICATIONS_FILE_PATH]) do
  #   pp "=================================="
  #   @@notifications = global_notifications
  # end

  # # byebug
  # pp ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
  # pp file_reloader.updated?
  # file_reloader.execute_if_updated
  def index
    # @@notifications ||= global_notifications
    @@notifications = global_notifications
    file_reloader = ActiveSupport::FileUpdateChecker.new([GLOBAL_NOTIFICATIONS_FILE_PATH]) do
      pp "=================================="
      @@notifications = global_notifications
    end

    # # byebug
    pp ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
    pp file_reloader.updated?
    # file_reloader.execute_if_updated

    render json: @@notifications.to_json
  end

  protected 

  def global_notifications 
    YAML.load(File.read(GLOBAL_NOTIFICATIONS_FILE_PATH))
    # JSON.parse(File.read(GLOBAL_NOTIFICATIONS_FILE_PATH))
  rescue => e
    pp e
    []
  end

end
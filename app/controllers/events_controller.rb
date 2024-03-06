require 'filewatcher'

class EventsController < ActionController::Base
  include ActionController::Live

  GLOBAL_NOTIFICATIONS_FILE_PATH = Rails.root.join('config', 'global_notifications', 'messages.json') 
  
  def index
    response.headers['Content-Type'] = 'text/event-stream'
    response.headers['Last-Modified'] = Time.now.httpdate

    sse = SSE.new(response.stream, event: "message")
    
    sse.write({ message: global_notifications, date: DateTime.now.to_s})
    
    Filewatcher.new([GLOBAL_NOTIFICATIONS_FILE_PATH]).watch do |changes|
      # next unless event_type.to_s.eql?('updated')
      changes.each do |filename, event|
        puts "#{filename} #{event}"
        sse.write({ message: global_notifications, date: DateTime.now.to_s})
      end
    end
  ensure
    sse.close
  end

  protected 

  def global_notifications 
    JSON.parse(File.read(GLOBAL_NOTIFICATIONS_FILE_PATH))
  rescue 
    []
  end
end
module Monitoring
  class AlarmState < Core::ServiceLayer::Model
    # The following properties are known
    # alarm_id
    # id
    # metrics
    # new_state
    # old_state
    # reason
    # reason_data
    # sub_alarms
    # timestamp
    #

    # TODO: better readable timestamp but untested because the api was not working :-(
    def timestamp()
      read(:timestamp) || nil
      return nil unless timestamp
      date,time_string = timestamp.split("T")
      time = time_string.split('.')[0]
      "#{time} #{date}"
    end

  end
end 

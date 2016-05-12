module Monitoring
  class Alarm < Core::ServiceLayer::Model
    # The following properties are known
    # id
    # metrics
    # state
    # alarm_definition
    # state_updated_timestamp
    # updated_timestamp
    # created_timestamp

    def severity
      alarm_definition = read(:alarm_definition)
      severity = alarm_definition["severity"]
      return nil unless severity
      severity
    end

    def alarm_definition_id
      alarm_definition = read(:alarm_definition)
      id = alarm_definition["id"]
      return nil unless id
      id
    end

    def state_updated_timestamp
      state_updated_timestamp = read(:state_updated_timestamp)
      if state_updated_timestamp
        convert_timestamp(state_updated_timestamp)
      end
    end

    def updated_timestamp
      updated_timestamp = read(:updated_timestamp)
      if updated_timestamp
        convert_timestamp(updated_timestamp)
      end
    end

    def created_timestamp
      created_timestamp = read(:created_timestamp)
      if created_timestamp
        convert_timestamp(created_timestamp)
      end
    end



    private

    def convert_timestamp(timestamp)
      date,time_string = timestamp.split("T")
      time = time_string.split('.')[0]
      "#{time} #{date}"
    end

  end
end

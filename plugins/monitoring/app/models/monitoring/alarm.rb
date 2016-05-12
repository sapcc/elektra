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
      read(:alarm_definition)["severity"] || nil
    end

    def alarm_definition_id
      read(:alarm_definition)["id"] || nil
    end

    def state_updated_timestamp
      convert_timestamp(read(:state_updated_timestamp))
    end

    def updated_timestamp
      convert_timestamp(read(:updated_timestamp))
    end

    def created_timestamp
      convert_timestamp(read(:created_timestamp))
    end

    private

    def convert_timestamp(timestamp)
      return nil unless timestamp
      date,time_string = timestamp.split("T")
      time = time_string.split('.')[0]
      "#{time} #{date}"
    end

  end
end

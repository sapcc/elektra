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

  end
end

module Monitoring
  class AlarmDefinition < Core::ServiceLayer::Model
    
    # The following properties are known
    # id
    # name
    # description
    # actions_enabled
    # expression
    # match_by
    # alarm_actions
    # undetermined_actions
    # ok_actions
    # severity

    validates_presence_of :name, :expression, :severity
  end
end

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

    def notification_action?
      actions_enabled && ( alarm_actions.length > 0 || ok_actions.length > 0 || undetermined_actions.length > 0 )
    end

  end
end

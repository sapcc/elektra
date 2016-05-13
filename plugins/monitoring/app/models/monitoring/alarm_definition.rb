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
    # https://github.com/openstack/monasca-api/blob/master/docs/monasca-api-spec.md#request-body-12
    validates :name, length: { maximum: 255 }
    validates :description, length: { maximum: 255 }

    def supported_severities
      [['Low','LOW'],['Medium','MEDIUM'],['High','HIGH'],['Critical','CRITICAL']] 
    end

    def match_by
      match_by = read(:match_by)
      return nil unless match_by
      return nil if match_by.empty?
      match_by.join(", ")
    end
  end
end

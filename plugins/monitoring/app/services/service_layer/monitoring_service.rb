module ServiceLayer

  class MonitoringService < Core::ServiceLayer::Service

    def driver
      @driver ||= Monitoring::Driver::Fog.new({
        auth_url:   self.auth_url,
        region:     self.region,
        token:      self.token,
        domain_id:  self.domain_id,
        project_id: self.project_id  
      })
    end
    
    def available?(action_name_sym=nil)
      true  
    end
    
    def alarm_definitions(filter = nil)
      alarm_definitions = driver.map_to(Monitoring::AlarmDefinition).alarm_definitions.sort_by(&:name)
      if filter
        filtered_alarm_definitons = []
        alarm_definitions.each do |alarm_definition|
          if alarm_definition.name.match filter or alarm_definition.description.match filter
            filtered_alarm_definitons << alarm_definition
          end
        end
        alarm_definitions = filtered_alarm_definitons
      end
      alarm_definitions
    end

    def alarms
      driver.map_to(Monitoring::AlarmDefinition).alarms
    end

    def notification_methods
      driver.map_to(Monitoring::NotificationMethod).notification_methods
    end

    def get_alarm_definition(id)
      id.blank? ? nil : driver.map_to(Monitoring::AlarmDefinition).get_alarm_definition(id)
    end

    def get_notification_method(id)
      id.blank? ? nil : driver.map_to(Monitoring::NotificationMethod).get_notification_method(id)
    end

    def new_notification_method(attributes={})
      Monitoring::NotificationMethod.new(driver,attributes)
    end

  end
end

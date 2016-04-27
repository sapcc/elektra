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
    
    def alarm_definitions
      driver.map_to(Monitoring::AlarmDefinition).alarm_definitions
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

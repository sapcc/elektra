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
    
    def alarm_definitions(search = nil)
      alarm_definitions = driver.map_to(Monitoring::AlarmDefinition).alarm_definitions.sort_by(&:name)
      if search
        alarm_definitons_search_results = []
        alarm_definitions.each do |alarm_definition|
          if alarm_definition.name.match search or alarm_definition.description.match search
            alarm_definitons_search_results << alarm_definition
          end
        end
        alarm_definitions = alarm_definitons_search_results
      end
      alarm_definitions
    end

    def alarms
      driver.map_to(Monitoring::AlarmDefinition).alarms
    end

    def notification_methods(search = nil)
      notification_methods = driver.map_to(Monitoring::NotificationMethod).notification_methods
      if search
        notification_methods_search_results = []
        notification_methods.each do |notification_method|
          if notification_method.name.match search or notification_method.address.match search
            notification_methods_search_results << notification_method
          end
        end
        notification_methods = notification_methods_search_results
      end
      notification_methods
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

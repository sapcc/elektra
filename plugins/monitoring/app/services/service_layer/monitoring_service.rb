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
      # TODO: use queries here
      # https://github.com/openstack/monasca-api/blob/master/docs/monasca-api-spec.md#query-parameters-13
       alarm_definitions = driver.map_to(Monitoring::AlarmDefinition).alarm_definitions.sort_by(&:name)
      if search
        alarm_definitions = alarm_definitions.select { |ad| ad.name.match(search) or ad.description.match(search) }
      end
      alarm_definitions
    end

    def alarms(options = {})
      driver.map_to(Monitoring::Alarm).alarms(options)
    end

    def notification_methods(search = nil)
      # TODO: use queries here
      # https://github.com/openstack/monasca-api/blob/master/docs/monasca-api-spec.md#query-parameters-8
       notification_methods = driver.map_to(Monitoring::NotificationMethod).notification_methods
      if search
        notification_methods = notification_methods.select { |nm| nm.name.match(search) or nm.address.match(search) }
      end
      notification_methods
    end

    def get_alarm_definition(id)
      id.blank? ? nil : driver.map_to(Monitoring::AlarmDefinition).get_alarm_definition(id)
    end

    def get_alarm(id)
      id.blank? ? nil : driver.map_to(Monitoring::Alarm).get_alarm(id)
    end

    def get_notification_method(id)
      id.blank? ? nil : driver.map_to(Monitoring::NotificationMethod).get_notification_method(id)
    end

    def new_notification_method(attributes={})
      Monitoring::NotificationMethod.new(driver,attributes)
    end

    def new_alarm_definition(attributes={})
      Monitoring::AlarmDefinition.new(driver,attributes)
    end


  end
end

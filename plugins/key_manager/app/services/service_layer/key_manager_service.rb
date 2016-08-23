module ServiceLayer

  class KeyManagerService < Core::ServiceLayer::Service

    def driver
      @driver ||= KeyManager::Driver::Fog.new({
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
    

    def secrets(filter={})
      ::KeyManager::Secret.create_secrets(driver.secrets(filter))
    end

    def secret(uuid)
      s = driver.secret(uuid)
      ::KeyManager::Secret.new(s.attributes)
    end

  end
end
module ServiceLayer

  class AuthorizationService < Core::ServiceLayer::Service

    def driver
      @driver ||= Authorization::Driver::MyDriver.new({
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
    

    def test
      driver.test
    end
  end
end
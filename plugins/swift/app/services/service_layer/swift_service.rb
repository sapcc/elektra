module ServiceLayer

  class SwiftService < DomainModelServiceLayer::Service

    def driver
      @driver ||= Swift::Driver::MyDriver.new({
        auth_url:   self.auth_url,
        region:     self.region,
        token:      self.token,
        domain_id:  self.domain_id,
        project_id: self.project_id  
      })
    end

    def test
      driver.test
    end
  end
end
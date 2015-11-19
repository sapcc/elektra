module ServiceLayer

  class ResourceManagementService < DomainModelServiceLayer::Service

    def driver
      @driver ||= ResourceManagement::Driver::Fog.new({
        auth_url: self.auth_url,
        region: self.region,
        token: self.token,
        domain_id: self.domain_id,
        project_id: self.project_id,
      })
    end

    def get_project_usage_swift(domain_id, project_id)
      return driver.get_project_usage_swift(domain_id, project_id)
    end

  end
end

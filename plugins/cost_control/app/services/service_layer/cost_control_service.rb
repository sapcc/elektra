module ServiceLayer
  class CostControlService < Core::ServiceLayer::Service

    def driver
      @driver ||= CostControl::Driver::Fog.new({
        auth_url:   self.auth_url,
        region:     self.region,
        token:      self.token,
        domain_id:  self.domain_id,
        project_id: self.project_id,
      })
    end

    def available?(action_name_sym=nil)
      not current_user.service_url('sap-billing', region: region).nil?
    end

    ##### project metadata

    def find_project_metadata(project_id)
      return nil if project_id.blank?
      driver.map_to(CostControl::ProjectMetadata).get_project_metadata(project_id)
    end

  end
end

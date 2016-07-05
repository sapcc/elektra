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
      not current_user.service_url('sapcc-billing', region: region).nil?
    end

    ##### project masterdata

    def find_project_masterdata(project_id)
      return new_project_masterdata if project_id.blank?
      driver.map_to(CostControl::ProjectMasterdata).get_project_masterdata(project_id)
    end

    def new_project_masterdata(attributes={})
      CostControl::ProjectMasterdata.new(driver, attributes)
    end

    ##### domain masterdata

    def find_domain_masterdata(domain_id)
      return nil if domain_id.blank?
      driver.map_to(CostControl::DomainMasterdata).get_domain_masterdata(domain_id)
    end
  end
end

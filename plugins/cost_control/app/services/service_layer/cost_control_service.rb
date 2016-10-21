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

    def new_domain_masterdata(attributes={})
      CostControl::DomainMasterdata.new(driver, attributes)
    end

    def find_domain_masterdata(domain_id)
      return new_domain_masterdata if domain_id.blank?
      driver.map_to(CostControl::DomainMasterdata).get_domain_masterdata(domain_id)
    end

    #### kb11n billing object

    def new_kb11n_billing_object(attributes={})
      CostControl::Kb11nBillingObject.new(driver, attributes)
    end

    def find_kb11n_billing_objects(project_id)
      unless @kb11n_billing_objects
        @kb11n_billing_objects = []
        kb11n_billing_objects = driver.map_to(CostControl::Kb11nBillingObject).get_kb11n_billing_objects(project_id)
        kb11n_billing_objects.each do |kb11n_billing_object|
          kb11n = new_kb11n_billing_object(kb11n_billing_object.attributes) if kb11n_billing_object.attributes
          @kb11n_billing_objects << kb11n if kb11n
        end
      end
      return @kb11n_billing_objects
    end

  end
end

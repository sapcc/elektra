module ServiceLayerNg

  class MasterdataCockpitService < Core::ServiceLayerNg::Service

    def available?(_action_name_sym = nil)
      api.catalog_include_service?('sapcc-analytics', region)
    end

    def missing_projects
      Rails.logger.debug  "[masterdata cockpit-service] -> missing_projects -> GET /missing}"
      api.masterdata.get_missing_project().map_to(MasterdataCockpit::ProjectMasterdata)
    end

    def get_project(project_id)
       Rails.logger.debug  "[masterdata cockpit-service] -> get_project -> GET /projects/#{project_id}"
       response = api.masterdata.get_project(project_id)
       map_to(MasterdataCockpit::ProjectMasterdata, response.body)
    end

    def get_domain(domain_id)
       Rails.logger.debug  "[masterdata cockpit-service] -> get_domain -> GET /domain/#{domain_id}"
       response = api.masterdata.get_domain(domain_id)
       map_to(MasterdataCockpit::DomainMasterdata, response.body)
    end

    def new_project_masterdata(params = {})
      Rails.logger.debug  "[masterdata cockpit-service] -> new_project_masterdata"
      # this is used for created masterdata dialog
      map_to(MasterdataCockpit::ProjectMasterdata, params)
    end

    def new_domain_masterdata(params = {})
      Rails.logger.debug  "[masterdata cockpit-service] -> new_domain_masterdata"
      # this is used for created masterdata dialog
      map_to(MasterdataCockpit::DomainMasterdata, params)
    end

    def create_domain_masterdata(masterdata)
      Rails.logger.debug  "[masterdata cockpit-service] -> create_domain_masterdata"
      Rails.logger.debug  "[masterdata cockpit-service] -> masterdata: #{masterdata}"
      response = api.masterdata.set_domain(masterdata["domain_id"],masterdata)
      response.body
    end

    def create_project_masterdata(masterdata)
      Rails.logger.debug  "[masterdata cockpit-service] -> create_project_masterdata"
      Rails.logger.debug  "[masterdata cockpit-service] -> masterdata: #{masterdata}"
      response = api.masterdata.set_project(masterdata["project_id"],masterdata)
      response.body
    end
    
    def get_solutions
      Rails.logger.debug  "[masterdata cockpit-service] -> get_solutions"
      response = api.masterdata.get_solutions
      map_to(MasterdataCockpit::CostControlSolution, response.body)
    end

  end
end

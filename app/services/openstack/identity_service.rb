module Openstack
  class IdentityService < OpenstackServiceProvider::FogProvider
    def driver(auth_params)
      Fog::IdentityV3::OpenStack.new(auth_params)
    end
        
    # returns domains which user has access to
    def user_domains(options={per_page: 30, page: 1})
      @driver.domains.auth_domains(options)
    end

    # returns domain which user has access to
    def user_domain(domain_id)
      @driver.domains.auth_domains.find_by_id(domain_id)
    end

    # returns domain projects which user has access to
    def user_domain_projects(domain_id,options={per_page: 30, page: 1})
      @driver.projects.all(domain_id: domain_id)  
    end
    
    # returns project which user has access to
    def user_project(project_id)
      @driver.projects.auth_projects.find_by_id(project_id) 
    end
    
    # returns all domain projects
    def domain_projects
      api_connection.projects.all(domain_id: domain_id)  
    end
    
    protected
    # admin connection to identity
    def api_connection
      @api_connection ||= MonsoonOpenstackAuth.api_client(@region).connection_driver.connection
    end
    
  end
end
module Openstack
  class IdentityService < OpenstackServiceProvider::FogProvider

    def driver(auth_params)
      # TODO: this line of code authenticates user and creates a new token in keystone.
      # this is not necessary because the user already exists in session and has a valid token.
      # It should be possible to create a fog instance without "new" authentication. It can use the token from session!
      Fog::IdentityV3::OpenStack.new(auth_params)
    end
    
    def has_projects?
      @driver.projects.auth_projects.count>0
    end
    
    ##################### DOMAINS #########################
    def find_domain(domain_id)
      @driver.domains.auth_domains.find_by_id(domain_id)
    end
    
    def domains
      @driver.domains.auth_domains
    end
    
    
    ##################### PROJECTS #########################
    def forms_project(id=nil)
      Forms::Project.new(self,id)
    end
    
    def create_project(options = {})
      @driver.projects.create(options)
    end
    
    def find_project(id)
      @driver.projects.auth_projects.find_by_id(id)
    end
    
    def projects
      @driver.projects.auth_projects
    end

    def grant_project_role(project,role_name)
      role = services.admin_identity.role(role_name)
      project.grant_role_to_user(role.id, @current_user.id)
    end  

    
    ##################### CREDENTIALS #########################
    def forms_credential(id=nil)
      Forms::Credential.new(self,id)
    end
    
    def create_credential(options = {})
      @driver.os_credentials.create(options)
    end
    
    def find_credential(id)
      @driver.os_credentials.find_by_id(id)
    end
    
    def credentials(options={})
      @driver.os_credentials
    end
  end
end

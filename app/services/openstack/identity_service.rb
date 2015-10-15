module Openstack
  class IdentityService < OpenstackServiceProvider::Service

    attr_reader :region

    def get_driver(params)
      OpenstackServiceProvider::FogDriver::Identity.new(params)
    end

    def has_projects?
      @driver.auth_projects.count>0
    end

    ##################### DOMAINS #########################
    def find_domain(domain_id)
      domains.find{|domain| domain.id==domain_id}
    end

    def domains
      @domains ||= @driver.auth_domains.collect{|attributes| Identity::Domain.new(attributes)}
    end


    ##################### PROJECTS #########################    
    def find_project_by_id(id,options=[])
      @driver.map_to(Identity::Project).get_project(id,options)
    end

    def auth_projects
      # caching
      @auth_projects ||= @driver.map_to(Identity::Project).auth_projects
    end

    def projects(domain_id=nil)
      return auth_projects if domain_id.nil?
      auth_projects.select {|project| project.domain_id==domain_id}
    end
    #
    # def grant_project_role(project,role_name)
    #   role = services.admin_identity.role(role_name)
    #   project.grant_role_to_user(role.id, @current_user.id)
    # end


    ##################### CREDENTIALS #########################
    def forms_credential(id=nil)
      Forms::Credential.new(self,id)
    end

    def create_credential(params)
      @driver.create_os_credentials(params)
    end

    def find_credential(id)
      @found_credentials ||= {}
      unless @found_credentials[id]
        @found_credentials[id] = credentials.find{|c| c.id==id}
      end
      @found_credentials[id]
      #@driver.os_credentials.find_by_id(id)
    end

    def credentials(options={})
      @user_credentials ||= @driver.os_credentials.all(user_id: @current_user.id)
      #@driver.os_credentials
    end
  end
end
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
    def domain(id)
      if id
        domains.find{|domain| domain.id==domain_id}
      else
        Identity::Domain.new(@driver)
      end 
    end

    def domains
      @domains ||= @driver.auth_domains.collect{|attributes| Identity::Domain.new(attributes)}
    end


    ##################### PROJECTS #########################    
    def project(id=nil,options=[])
      if id
        @driver.map_to(Identity::Project).get_project(id,options)
      else
        Identity::Project.new(@driver)
      end 
    end

    def auth_projects
      # caching
      @auth_projects ||= @driver.map_to(Identity::Project).auth_projects
    end

    def projects(domain_id=nil)
      return auth_projects if domain_id.nil?
      auth_projects.select {|project| project.domain_id==domain_id}
    end

    def grant_project_role(project,role_name)
      role = services.admin_identity.role(role_name)
      @driver.grant_project_user_role(project_id,@current_user.id,role.id)
    end


    ##################### CREDENTIALS #########################
    def credential(id=nil)
      if id
        @driver.map_to(Identity::OsCredential).get_os_credential(id)
      else
        Identity::OsCredential.new(@driver)
      end
    end

    def credentials(options={})
      @user_credentials ||= @driver.map_to(Identity::OsCredential).os_credentials(user_id: @current_user.id)
    end
  end
end
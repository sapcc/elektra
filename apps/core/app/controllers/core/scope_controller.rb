module Core
  # This class guarantees that a scope is presented.
  # All subclasses which require a scope (e.g. domain_id/projects or domain_id/project_id/instances) 
  # should inherit from this class.
  class ScopeController < ApplicationController

    # includes services method
    # use: services.SERVICE_NAME.METHOD_NAME (e.g. services.identity.projects)
    include OpenstackServiceProvider::Services
  
    prepend_before_filter do
      # initialize scoped domain's and project's friendly id 
      # use existing, user's or default domain
      domain_id = (params[:domain_id] || current_user.try(:user_domain_id) || MonsoonOpenstackAuth.configuration.default_domain_name) 
      project_id = params[:project_id]
    
      @scoped_domain_fid = @scoped_domain_id = domain_id 
      @scoped_project_fid = @scoped_project_id = project_id
    
      # try to find or create friendly_id entry for domain
      domain_friendly_id = services.admin_identity.domain_friendly_id(@scoped_domain_fid)
      if domain_friendly_id
        # set scoped domain parameters
        @scoped_domain_id   = domain_friendly_id.key
        @scoped_domain_fid  = domain_friendly_id.slug
        @scoped_domain_name = domain_friendly_id.name

        # try to load or create friendly_id entry for project
        project_friendly_id = services.admin_identity.project_friendly_id(@scoped_domain_id, @scoped_project_fid) if @scoped_project_id

        if project_friendly_id
          # set scoped project parameters
          @scoped_project_id  = project_friendly_id.key
          @scoped_project_fid = project_friendly_id.slug
        end

        if domain_id!=@scoped_domain_fid or project_id!=@scoped_project_fid
          redirect_to url_for(params.merge(domain_id: @scoped_domain_fid, project_id: @scoped_project_fid))
        end
      else
        @errors = {"domain" => "Not found"}
        render template: 'core/application/error'
      end
      #p ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
      #p "@scoped_domain_id: #{@scoped_domain_id}"
      #p "@scoped_domain_fid: #{@scoped_domain_fid}"
      #p "@scoped_domain_name: #{@scoped_domain_name}"
      #p "@scoped_project_id: #{@scoped_project_id}"
      #p "@scoped_project_fid: #{@scoped_project_fid}"
    end
  

    def url_options
      { domain_id: @scoped_domain_fid, project_id: @scoped_project_fid }.merge(super)
    end

  end
end
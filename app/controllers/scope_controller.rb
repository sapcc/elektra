# This class guarantees that a scope is presented.
# All subclasses which require a scope (e.g. domain_id/projects or domain_id/project_id/instances) 
# should inherit from this class.
class ScopeController < ::ApplicationController

  prepend_before_filter do
    # initialize scoped domain's and project's friendly id 
    # use existing, user's or default domain
    domain_id = (params[:domain_id] || service_user.try(:domain_id))     
    project_id = params[:project_id]
    
    if service_user.nil?
      raise Core::Error::ServiceUserNotAuthenticated.new("Could not authenticate service user. Please check permissions on #{params[:domain_id]} for service user #{Rails.application.config.service_user_id}") 
    end

    @scoped_domain_fid = @scoped_domain_id = domain_id 
    @scoped_project_fid = @scoped_project_id = project_id
  
    # try to find or create friendly_id entry for domain
    rescoping_service = Dashboard::RescopingService.new(service_user)
    domain_friendly_id = rescoping_service.domain_friendly_id(@scoped_domain_fid)
    
    if domain_friendly_id
      # set scoped domain parameters
      @scoped_domain_id   = domain_friendly_id.key
      @scoped_domain_fid  = domain_friendly_id.slug
      @scoped_domain_name = domain_friendly_id.name

      # try to load or create friendly_id entry for project
      project_friendly_id = rescoping_service.project_friendly_id(@scoped_domain_id, @scoped_project_fid) if @scoped_project_id

      if project_friendly_id
        # set scoped project parameters
        @scoped_project_id   = project_friendly_id.key
        @scoped_project_fid  = project_friendly_id.slug
        @scoped_project_name = project_friendly_id.name
      end

      if (domain_id!=@scoped_domain_fid and domain_id!=@scoped_domain_name) or project_id!=@scoped_project_fid
        #redirect_to url_for(params.merge(domain_id: @scoped_domain_fid, project_id: @scoped_project_fid))

        # url_for does not work for plugins. Use path instead!
        if @scoped_domain_id
          # new_path = request.path.gsub(@scoped_domain_id,@scoped_domain_fid).gsub(@scoped_domain_name,@scoped_domain_fid)
          new_path = request.path.gsub(@scoped_domain_id,@scoped_domain_fid)
          new_path = "/#{@scoped_domain_fid}#{new_path}" unless new_path.include?(@scoped_domain_fid)
          # replace project_id with freindly id if given
          new_path = new_path.gsub(@scoped_project_id,@scoped_project_fid) if @scoped_project_id
          redirect_to new_path
        end     
      end
    else
      raise Core::Error::DomainNotFound.new("Domain #{domain_id} not found!")
    end
    # p ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
    # p "domain_id: #{domain_id}"
    # p "project_id: #{project_id}"
    # p "@scoped_domain_id: #{@scoped_domain_id}"
    # p "@scoped_domain_fid: #{@scoped_domain_fid}"
    # p "@scoped_domain_name: #{@scoped_domain_name}"
    # p "@scoped_project_id: #{@scoped_project_id}"
    # p "@scoped_project_fid: #{@scoped_project_fid}"
  end
  
  render_error_page_for [
    {
      "Core::Error::ServiceUserNotAuthenticated" => {
        title: "Unsupported Domain",
        description: "Dashboard is not enabled for this domain.",
        details: :message
      }
    },
    {
      "Core::Error::DomainNotFound" => {title: 'Bad Domain'}
    }
  ]
end
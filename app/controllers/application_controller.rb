class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  include OpenstackServiceProvider::Services

  prepend_before_filter do
    domain_id = params[:domain_id] || MonsoonOpenstackAuth.configuration.default_domain_name
    project_id = params[:project_id]
    
    @scoped_domain_fid = domain_id
    @scoped_project_fid = project_id

    local_domain = services.admin_identity.find_or_create_local_domain(domain_id) if domain_id

    if local_domain
      # get domain info
      @scoped_domain_id   = local_domain.key
      @scoped_domain_fid  = local_domain.slug
      @scoped_domain_name = local_domain.name

      if project_id
        local_project       = services.admin_identity.find_or_create_local_project(local_domain,project_id)
        @scoped_project_id  = local_project.key if local_project
        @scoped_project_fid = local_project.slug if local_project
      end

      if domain_id!=@scoped_domain_fid or project_id!=@scoped_project_fid
        redirect_to url_for(params.merge(domain_id: @scoped_domain_fid, project_id: @scoped_project_fid))
      end
    else
      @errors = {"domain" => "Not found"}
      render template: 'application/error'
    end
  end

  def url_options
    { domain_id: @scoped_domain_fid, project_id: @scoped_project_fid }.merge(super)
  end

  helper_method :modal?

  def modal?
    if @modal.nil?
      @modal = (request.xhr? and params[:modal]) ? true : false
    end
    @modal
  end

  def render(*args)
    options = args.extract_options!
    options.merge! layout: 'modal' if modal?
    super *args, options
  end

  def redirect_to(options)
    if modal?
      head :ok, location: url_for(options)
    else
      super options
    end
  end

end

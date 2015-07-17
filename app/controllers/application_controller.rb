class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  include OpenstackServiceProvider::Services

  prepend_before_filter do

    @region ||= MonsoonOpenstackAuth.configuration.default_region

    if params[:domain_fid]
      fid = params[:domain_fid]
    else
      fid = 'sap_default'
    end

    domain = ::Domain.friendly_find_or_create @region, fid
    @domain_fid = domain.slug
    @domain_id = domain.key

    if params[:project_fid]
      fid = params[:project_fid]
      project = ::Project.friendly_find_or_create @region, domain, fid
      @project_fid ||= project.slug
      @project_id ||= project.key
    end
  end
  
  helper_method :modal?

  def modal?
    if @modal.nil?
      @modal = request.xhr? ? true : false 
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

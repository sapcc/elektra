class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  include OpenstackServiceProvider::Services

  prepend_before_filter do

    @region ||= MonsoonOpenstackAuth.configuration.default_region

    fid = params[:domain_fid] || 'sap_default'

    begin
      domain = ::Domain.friendly_find_or_create @region, fid
      @domain_fid = domain.slug
      @domain_id = domain.key

      if params[:project_fid]
        fid = params[:project_fid]
        project = ::Project.friendly_find_or_create @region, domain, fid
        @project_fid ||= project.slug
        @project_id ||= project.key
      end
    rescue => exception
      @errors = {exception.class.name => exception.message}
      render template: 'application/error'
    end
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

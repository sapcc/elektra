class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  prepend_before_filter do
    if params[:domain_id]
      @domain_id ||= params[:domain_id]
      #@domain ||= services.identity.find_domain(@domain_id)
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
    url = url_for(options)
    p ">>>>>>>>>>>>>>>"
    p url
    p monsoon_openstack_auth.new_session_path
    if modal? and url!=monsoon_openstack_auth.new_session_path
      head :ok, location: url_for(options)
    else
      super options
    end
  end

end

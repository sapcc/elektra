# This class implements functionality to support modal views.
# All subclasses which require modal views should inherit from this class.
class ApplicationController < ActionController::Base
  layout 'application'
  include ApplicationHelper
  
  # includes services method
  # use: services.SERVICE_NAME.METHOD_NAME (e.g. services.identity.auth_projects)
  include Services  
  include ServiceUser
  include CurrentUserWrapper

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  
  helper_method :modal?, :plugin_name
  
  # check if the requested domain is the same as that of the current user.
  before_filter :same_domain_check
  
  # token is expired or was revoked -> redirect to login page
  rescue_from "Core::ServiceUser::Errors::AuthenticationError" do
    render 'application/domain_forbidden'
  end
  

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

  def redirect_to(options = {}, response_status = {})
    if modal? or params[:polling_service]
      head :ok, location: url_for(options)
    else
      super options, response_status
    end
  end

  def plugin_name
    if @plugin_name.blank?
      tokens = self.class.name.split('::').collect{|token| token.underscore}
      @plugin_name = tokens.find{|t| Core::PluginsManager.plugin?(t)}
    end
    @plugin_name
  end
  
  protected
  
  def same_domain_check
    if current_user and current_user.user_domain_id and service_user and service_user.domain_id
      if current_user.user_domain_id!=service_user.domain_id
        # requested domain differs from the domain of current user
        @current_domain_name = current_user.user_domain_name
        @new_domain_name = service_user.domain_name

        # render domain switch view
        render template: 'application/domain_switch'
      end
    end
  end
end

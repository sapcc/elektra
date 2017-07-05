

require 'core/audit_logger'
# This class implements functionality to support modal views.
# All subclasses which require modal views should inherit from this class.
class ApplicationController < ActionController::Base
  layout 'application'
  include ApplicationHelper

  # includes services method
  # use: services.SERVICE_NAME.METHOD_NAME
  # (e.g. services.identity.auth_projects)
  # TODO: should be removed after switch to misty
  include Services

  include ServicesNg
  # TODO: should be removed after switch to misty
  include ServiceUser

  include CurrentUserWrapper
  include Core::Paginatable

  extend ErrorRenderer

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  helper_method :modal?, :plugin_name

  # check if the requested domain is the same as that of the current user.
  before_filter :same_domain_check

  # catch all api errors and render exception page
  rescue_and_render_exception_page [
    { 'Excon::Error' => { title: 'Backend Service Error' } },
    { 'Fog::OpenStack::Errors::ServiceError' => {
      title: 'Backend Service Error'
    } }
  ]

  def modal?
    if @modal.nil?
      @modal = request.xhr? && params[:modal] ? true : false
    end
    @modal
  end

  def render(*args)
    options = args.extract_options!
    options[:layout] = 'modal' if modal?
    super *args, options
  end

  def redirect_to(options = {}, response_status = {})
    if request.format == Mime::JSON ||
       modal? || params[:polling_service] || params[:do_not_redirect]
      head :ok, location: url_for(options)
    else
      super options, response_status
    end
  end

  def plugin_name
    if @plugin_name.blank?
      tokens = self.class.name.split('::').collect { |token| token.underscore }
      @plugin_name = tokens.find { |t| Core::PluginsManager.plugin?(t) }
    end
    @plugin_name
  end

  protected

  def same_domain_check
    if current_user && current_user.user_domain_id &&
       service_user && service_user.domain_id
      if current_user.user_domain_id != service_user.domain_id
        # requested domain differs from the domain of current user
        @current_domain_name = current_user.user_domain_name
        @new_domain_name = service_user.domain_name

        @domain_switch = true
        # render domain switch view
        render template: 'application/domain_switch'
      end
    end
  end
end

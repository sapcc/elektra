

require 'core/audit_logger'
# This class implements functionality to support modal views.
# All subclasses which require modal views should inherit from this class.
class ApplicationController < ActionController::Base
  layout 'application'
  include ApplicationHelper

  # includes services method
  # use: services.SERVICE_NAME.METHOD_NAME
  # (e.g. services.identity.auth_projects)
  include Services
  include CurrentUserWrapper
  include Core::Paginatable

  extend ErrorRenderer

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  helper_method :modal?, :plugin_name, :modal_size

  # catch all api errors and render exception page

  rescue_from 'Elektron::Errors::Request' do |exception|
    options = {
      title: 'Backend Slowdown Detected',
      description: 'We are currently experiencing a higher latency in our ' \
                   'backend calls. This should be fixed momentarily. Please ' \
                   'try again in a couple of minutes.',
      warning: true, sentry: false
    }

    # send to sentry if exception isn't a timeout error
    options[:sentry] = true unless exception.message == 'Net::ReadTimeout'

    render_exception_page(exception, options)
  end

  def modal?
    if @modal.nil?
      @modal = request.xhr? && params[:modal] ? true : false
    end
    @modal
  end

  def modal_size
    params[:modal_size] || "modal-xl"
  end

  def render(*args)
    options = args.extract_options!
    options[:layout] = 'modal' if modal?
    super *args, options
  end

  def redirect_to(options = {}, response_status = {})
    if request.format == Mime[:json] ||
       modal? || params[:polling_service] || params[:do_not_redirect]
      head :ok, location: url_for(options)
    else
      super options, response_status
    end
  end

  def plugin_name
    if @plugin_name.blank?
      tokens = self.class.name.split('::').collect(&:underscore)
      @plugin_name = tokens.find { |t| Core::PluginsManager.plugin?(t) }
    end
    @plugin_name
  end
end

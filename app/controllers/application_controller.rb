# This class implements functionality to support modal views.
# All subclasses which require modal views should inherit from this class.
class ApplicationController < ActionController::Base
  layout 'application'

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  helper_method :modal?, :plugin_name

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

  def plugin_name
    if @plugin_name.blank?
      tokens = self.class.name.split('::').collect{|token| token.underscore}
      @plugin_name = tokens.find{|t| PluginsManager.plugin?(t)}
    end
    @plugin_name
  end

end

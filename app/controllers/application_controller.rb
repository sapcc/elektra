# This class implements functionality to support modal views.
# All subclasses which require modal views should inherit from this class.
class ApplicationController < ActionController::Base
  layout 'application'
  include ApplicationHelper

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
    if modal? or params[:polling_service]
      head :ok, location: url_for(options)
    else
      super options
    end
  end
  
  # Redefine current_user method which comes from monsoon_openstack_auth gem.
  # This method wraps current_user and adds some details like email and full_name.
  def current_user
    return nil if super.nil?
    CurrentUserWrapper.new(super,session)
  end

  def plugin_name
    if @plugin_name.blank?
      tokens = self.class.name.split('::').collect{|token| token.underscore}
      @plugin_name = tokens.find{|t| PluginsManager.plugin?(t)}
    end
    @plugin_name
  end
  
  protected
  
  # Wrapper for current user
  class CurrentUserWrapper
    def initialize(current_user, session)
      @current_user = current_user
      @session = session
      # already saved user details in session
      old_user_details = (@session[:current_user_details] || {})
      
      # check if user id from session differs from current_user id
      if old_user_details["id"]!=current_user.id
        # load user details for current_user
        new_user_details = Admin::IdentityService.find_user(current_user.id) rescue nil
        if new_user_details 
          # save user_details in session
          @session[:current_user_details] = new_user_details.nil? ? {} : new_user_details.attributes.merge("id"=>new_user_details.id)
        end
      end
    end
    
    # delegate all methods to wrapped current user  
    def method_missing(name, *args, &block)
      @current_user.send(name,*args,&block)
    end

    # Email is not provided by current_user. So add it here.
    def email
      @session[:current_user_details]["email"] if @session[:current_user_details]
    end
    
    # Fullname is not provided by current_user. So add it here.
    def full_name
      @session[:current_user_details]["description"] if @session[:current_user_details]
    end
    
    def cloud_admin?
      @current_user.admin? and (@current_user.user_domain_name=='monsooncc')
    end
    
    def domain_admin?
      @current_user.admin? and !@current_user.domain_id.nil?
    end
    
    def project_admin?
      @current_user.admin? and !@current_user.project_id.nil?
    end
  end

end

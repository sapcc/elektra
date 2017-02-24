# This class guarantees that the user is logged in and his token is rescoped.
# All subclasses which require a logged in user should inherit from this class.
class DashboardController < ::ScopeController
  include UrlHelper

  prepend_before_filter do
    # session[:monsoon_openstack_auth_token]["expires_at"]=(Time.now-1.minute).to_s
    requested_url = request.env['REQUEST_URI']
    referer_url = request.referer
    referer_url = "#{URI(referer_url).path}?#{URI(referer_url).query}" rescue nil

    unless params[:after_login]
      if requested_url=~/(\?|\&)modal=true/ and referer_url=~/(\?|\&)overlay=.+/
        params[:after_login] = referer_url
      else
        params[:after_login] = requested_url
      end
    end
  end

  before_filter :load_help_text;

  # authenticate user -> current_user is available
  authentication_required domain: -> c { c.instance_variable_get("@scoped_domain_id") },
                          domain_name: -> c { c.instance_variable_get("@scoped_domain_name") },
                          project: -> c { c.instance_variable_get('@scoped_project_id') },
                          rescope: false,
                          except: :terms_of_use

  # after_login is used by monsoon_openstack_auth gem.
  # After the authentication process has finished the after_login can be removed.
  before_filter{params.delete(:after_login)}

  # check if user has accepted terms of use. Otherwise it is a new, unboarded user.
  before_filter :check_terms_of_use, except: [:accept_terms_of_use, :terms_of_use]
  # rescope token
  before_filter :rescope_token, except: [:terms_of_use]
  before_filter :raven_context, except: [:terms_of_use]
  before_filter :load_user_projects, except: [:terms_of_use]
  before_filter :set_mailer_host

  # even if token is not expired yet we get sometimes the error "token not found"
  # so we try to catch this error here and redirect user to login screen
  rescue_from "Excon::Error::NotFound" do |error|
    if error.message.match(/Could not find token/i) or error.message.match(/Failed to validate token/i)
      redirect_to monsoon_openstack_auth.login_path(domain_name: @scoped_domain_name, after_login: params[:after_login])
    else
      render_exception_page(error,{title: 'Backend Service Error'})
    end
  end

  rescue_from "Core::ServiceLayer::Errors::ApiError" do |error|
    if error.response_data and error.response_data["error"] and error.response_data["error"]["code"]==403
      render_exception_page(error,{title: 'Permission Denied', description: error.response_data["error"]["message"] || "You are not authorized to request this page."})
    else
      render_exception_page(error, title: 'Backend Service Error')
    end
  end

  rescue_from "Excon::Error::Unauthorized","MonsoonOpenstackAuth::Authentication::NotAuthorized" do
    redirect_to monsoon_openstack_auth.login_path(domain_name: @scoped_domain_name, after_login: params[:after_login])
  end

  # catch all mentioned errors and render error page
  rescue_and_render_exception_page [
    {
      "MonsoonOpenstackAuth::Authorization::SecurityViolation" => {
        title: 'Unauthorized',
        sentry: false,
        warning: true,
        status: 401,
        description: -> (e,c) {
          m = 'You are not authorized to view this page.'
          if e.involved_roles and e.involved_roles.length>0
            m += " Please check (role assignments) if you have one of the following roles: #{e.involved_roles.flatten.join(', ')}."
          end
          m
        }
      }
    },
    {"Core::Error::ProjectNotFound" => {title: 'Project Not Found'}}
  ]

  def rescope_token
    if @scoped_project_id.nil? and service_user.role_assignments("user.id" => current_user.id, "scope.domain.id" => @scoped_domain_id, "effective" => true).empty?
      authentication_rescope_token(domain: nil, project: nil)
    else
      authentication_rescope_token
    end
  end

  def check_terms_of_use
    unless tou_accepted?
      render action: :accept_terms_of_use and return
    end
  end

  def accept_terms_of_use
    if params[:terms_of_use]
      # user has accepted terms of use -> onboard user
      UserProfile.create_with(name: current_user.name, email: current_user.email, full_name: current_user.full_name)
          .find_or_create_by(uid: current_user.id)
          .domain_profiles.create(domain_id: current_user.user_domain_id, tou_version: Settings.actual_terms.version)
      reset_last_request_cache
      # redirect to domain path
      if plugin_available?('identity')
        redirect_to plugin('identity').domain_path
      else
        redirect_to main_app.root_path
      end
    else
      check_terms_of_use
    end
  end

  def terms_of_use
    if current_user
      @tou = UserProfile.tou(current_user.id, current_user.user_domain_id, Settings.actual_terms.version)
    end
    render action: :terms_of_use
  end

  def find_users_by_name
    name = params[:name] || params[:term] || ""
    users = UserProfile.search_by_name name

    # sample users uniq
    result = {}
    users.each do |u|
      unless result[u.name]
        result[u.name] = {id: u.uid, name: u.name, full_name: u.full_name, email: u.email }
      end
    end

    respond_to do |format|
      format.html { render :json => result.values }
      format.json { render :json => result.values }
    end
  end

  def find_cached_domains
    name = params[:name] || params[:term] || ""
    domains = FriendlyIdEntry.search('Domain',nil,name)
    render json: domains.collect{|d| {id: d.key, name: d.name}}.to_json
  end

  def find_cached_projects
    name = params[:name] || params[:term] || ""
    projects = FriendlyIdEntry.search('Project',@scoped_domain_id,name)
    render json: projects.collect{|project| {id: project.key, name: project.name}}.to_json
  end

  protected

  helper_method :release_state

  # Overwrite this method in your controller if you want to set the release state of your plugin to a different value. A tag will be displayed in the main toolbar next to the page header
  # DON'T OVERWRITE THE VALUE HERE IN THE DASHBOARD CONTROLLER
  # Possible values:
  # ----------------
  # "public_release"  (plugin is properly live and works)
  # "experimental"    (for plugins that barely work or don't work at all)
  # "tech_preview"    (default)
  # "beta"            (if it's almost ready for public release)
  def release_state
    "tech_preview"
  end

  def show_beta?
    params[:betafeatures] == 'showme'
  end
  helper_method :show_beta?

  def raven_context

    @sentry_user_context = {
      ip_address: request.ip,
      id: current_user.id,
      email: current_user.email,
      username: current_user.name,
      domain: current_user.user_domain_name,
      name: current_user.full_name
    }.reject {|_,v| v.nil?}

    Raven.user_context(
      @sentry_user_context
    )

    tags = {}
    tags[:request_id] = request.uuid if request.uuid
    tags[:plugin] = plugin_name if try(:plugin_name).present?
    if current_user.domain_id
      tags[:domain_id] = current_user.domain_id
      tags[:domain_name] = current_user.domain_name
    elsif current_user.project_id
      tags[:project_id] = current_user.project_id
      tags[:project_name] = current_user.project_name
      tags[:project_domain_id] = current_user.project_domain_id
      tags[:project_domain_name] = current_user.project_domain_name
    end
    @sentry_tags_context = tags
    Raven.tags_context(tags)
  end

  def load_user_projects
    # get all projects for user (this might be expensive, might need caching, ajaxifying, ...)
    #@user_domain_projects ||= services.identity.auth_projects(@scoped_domain_id).sort_by { |project| project.name } rescue []
    @user_domain_projects ||= service_user.user_projects(current_user.id, {domain_id: @scoped_domain_id}).sort_by { |project| project.name } rescue []

    # load active project
    if @scoped_project_id
      # @active_project ||= @user_domain_projects.find { |project| project.id == @scoped_project_id }
      @active_project = services.identity.find_project(@scoped_project_id, [:subtree_as_ids, :parents_as_ids])
      FriendlyIdEntry.update_project_entry(@active_project)
      @webcli_endpoint = current_user.service_url("webcli")
    end

  end

  def tou_accepted?
    # Consider that every plugin controller inhertis from dashboard controller
    # and check_terms_of_use method is called on every request.
    # In order to reduce api calls we cache the result of new_user?
    # in the session for 5 minutes.
    is_cache_expired = current_user.id!=session[:last_user_id] ||
        session[:last_request_timestamp].nil? ||
        (session[:last_request_timestamp] < Time.now-5.minute)
    if is_cache_expired
      session[:last_request_timestamp] = Time.now
      session[:last_user_id] = current_user.id
      session[:tou_accepted] =
      if UserProfile.tou_accepted?(current_user.id, current_user.user_domain_id, Settings.actual_terms.version)
        session[:tou_accepted] = true
      else
        session[:tou_accepted] = false
      end
    end
    session[:tou_accepted]
  end


  def reset_last_request_cache
    session[:last_request_timestamp]=nil
    session[:last_user_id]=nil
  end

  def set_mailer_host
    ActionMailer::Base.default_url_options[:host] = request.host_with_port
    ActionMailer::Base.default_url_options[:protocol] = request.protocol
  end

  def project_id_required
    raise Core::Error::ProjectNotFound.new("The project you have requested was not found.") if params[:project_id].blank?
  end

  def load_help_text
    plugin_path = params[:controller]

    plugin_index = Core::PluginsManager.available_plugins.find_index{ |p| plugin_path.starts_with?(p.name)}
    plugin = Core::PluginsManager.available_plugins.fetch(plugin_index, nil) unless plugin_index.blank?


    unless plugin.blank?

      # get name of the specific service inside the plugin
      # remove plugin name from path
      path = plugin_path.split('/')
      path.shift
      service_name = path.join('_')

      # try to find the help file, check first for service specific help file, next for general plugin help file
      help_file =  File.join(plugin.path,"plugin_#{service_name}_help.md")
      help_file =  File.join(plugin.path,"plugin_help.md") unless File.exists?(help_file)

      # try to find the links file, check first for service specific links file, next for general plugin links file
      help_links = File.join(plugin.path,"plugin_#{service_name}_help_links.md")
      help_links = File.join(plugin.path,"plugin_help_links.md") unless File.exists?(help_links)


      # load plugin specific help text
      @plugin_help_text = File.new(help_file, "r").read if File.exists?(help_file)

      # load plugin specific help links
      if File.exists?(help_links)
        @plugin_help_links = File.new(help_links, "r").read
        @plugin_help_links = @plugin_help_links.gsub('#{@sap_docu_url}', sap_url_for('documentation'))
      end

    end

  end

end

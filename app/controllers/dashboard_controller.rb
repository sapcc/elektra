# This class guarantees that the user is logged in and his token is rescoped.
# All subclasses which require a logged in user should inherit from this class.
class DashboardController < ::ScopeController
  # authenticate user -> current_user is available
  authentication_required domain: -> c { c.instance_variable_get("@scoped_domain_id") },
                          domain_name: -> c { c.instance_variable_get("@scoped_domain_name") },
                          project: -> c { c.instance_variable_get('@scoped_project_id') },
                          rescope: false, # do not rescope after authentication

                          redirect_to: -> current_user, requested_url, referer_url {
                            # do stuff after user has logged on bevore redirect to requested url

                            # if the new scope domain which user has logged in differs from the scope in requested url 
                            # then redirect user to home page of the new domain.  
                            if requested_url.blank? or (!(requested_url=~/^[^\?]*#{current_user.user_domain_name}/) and !(requested_url=~/^[^\?]*#{current_user.user_domain_id}/))
                              "/#{current_user.user_domain_id}/identity/home"
                            else
                              # new domain is the same but the requested_url contains modal parameter and the referer url contains overlay parameter
                              # in this case the requested_url came from a modal window. So we do not redirect user to the requested_url
                              # but to the referer url.
                              if requested_url=~/(\?|\&)modal=true/ and referer_url=~/(\?|\&)overlay=.+/
                                referer_url
                              else
                                # in all other cases redirect user to requested url
                                requested_url
                              end
                            end
                          }

  # check if user has accepted terms of use. Otherwise it is a new, unboarded user.
  before_filter :check_terms_of_use, except: [:accept_terms_of_use]
  # rescope token
  before_filter :rescope_token
  before_filter :raven_context
  before_filter :load_user_projects
  before_filter :set_mailer_host

  # token is expired or was revoked -> redirect to login page
  rescue_from "Identity::InvalidToken" do
    redirect_to monsoon_openstack_auth.login_path(domain_name: @scoped_domain_name)
  end
  
  rescue_from "MonsoonOpenstackAuth::Authentication::NotAuthorized" do
    redirect_to monsoon_openstack_auth.login_path(domain_name: @scoped_domain_name)
  end

  def rescope_token
    if @scoped_project_id.nil? and service_user.role_assignments("user.id" => current_user.id, "scope.domain.id" => @scoped_domain_id, "effective" => true).empty?
      authentication_rescope_token(domain: nil, project: nil)
    else
      authentication_rescope_token
    end
  end

  def check_terms_of_use
    return if Rails.env == "test"
    unless tou_accepted?
      render action: :terms_of_use and return
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
      group_name = "CC_#{current_user.user_domain_name.upcase}_DOMAIN_MEMBERS"
      @service_user.remove_user_from_group(current_user.id, group_name)
      render action: :terms_of_use
    end
  end

  def find_users_by_name
    name = params[:name] || params[:term] || ""
    users = UserProfile.search_by_name name
    users.collect! {|u| {id: u.uid, name: u.name, full_name: u.full_name, email: u.email } }
    respond_to do |format|
      format.html { render :json => users }
      format.json { render :json => users }
    end
  end

  protected

  def raven_context
    Raven.user_context(
        ip_address: request.ip,
        id: current_user.id,
        email: current_user.email,
        username: current_user.name,
        domain: current_user.user_domain_name
    )

    tags = {}
    if current_user.domain_id
      tags[:domain_id] = current_user.domain_id
      tags[:domain_name] = current_user.domain_name
    elsif current_user.project_id
      tags[:project_id] = current_user.project_id
      tags[:project_name] = current_user.project_name
      tags[:project_domain_id] = current_user.project_domain_id
      tags[:project_domain_name] = current_user.project_domain_name
    end
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
      @webcli_endpoint = current_user.service_url("webcli")
    end

  end

  def authorization_forbidden exception
    @exception = exception
    respond_to do |format|
      format.html { render "dashboard/forbidden", :status => :forbidden }
      format.js { render "dashboard/forbidden.js" }
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
    if true #is_cache_expired
      session[:last_request_timestamp] = Time.now
      session[:last_user_id] = current_user.id
      session[:tou_accepted] =
          profile = UserProfile.find_by(uid: current_user.id).domain_profiles.find_by(domain_id: current_user.user_domain_id, tou_version: Settings.actual_terms.version) rescue false
      if profile
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


end

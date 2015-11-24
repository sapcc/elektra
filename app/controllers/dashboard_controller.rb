# This class guarantees that the user is logged in and his token is rescoped.
# All subclasses which require a logged in user should inherit from this class.
class DashboardController < ::ScopeController
  # load region, domain and project if given
  prepend_before_filter do
    # initialize session unless loaded yet
    session[:init] = true unless session.loaded?
  end

  # authenticate user -> current_user is available
  authentication_required domain: -> c { c.instance_variable_get("@scoped_domain_id") },
                          project: -> c { c.instance_variable_get('@scoped_project_id') },
                          rescope: false # do not rescope after authentication

  # check if user has accepted terms of use. Otherwise it is a new, unboarded user.
  before_filter :check_terms_of_use, except: [:new_user,:register_user]
  # rescope token
  before_filter :authentication_rescope_token, except: [:new_user,:register_user]
  before_filter :load_user_projects, except: [:new_user,:register_user]


  rescue_from "Excon::Errors::Forbidden", with: :handle_api_error
  rescue_from "Excon::Errors::InternalServerError", with: :handle_api_error
  rescue_from "Excon::Errors::Unauthorized", with: :handle_api_error
  rescue_from "MonsoonOpenstackAuth::ApiError", with: :handle_auth_error
  rescue_from "MonsoonOpenstackAuth::Authentication::NotAuthorized", with: :handle_auth_error

  def check_terms_of_use
    if Admin::OnboardingService.new_user?(current_user)
      # new user: user has not a role for requested domain or user has no project yet.
      # save current_url in session
      session[:requested_url] = request.env['REQUEST_URI']
      # redirect to user onboarding page.
      redirect_to "/#{@scoped_domain_fid}/onboarding" and return
    end
  end

  # render new user template
  def new_user
  end

  # onboard new user
  def register_user
    if params[:terms_of_use]
      # user has accepted terms of use -> onboard user
      Admin::OnboardingService.register_user(current_user)

      # redirect to sandbox (friendly url)
      redirect_to main_app.domain_home_path
    else
      render action: :new
    end
  end

  protected

  def load_user_projects
    # get all projects for user (this might be expensive, might need caching, ajaxifying, ...)
    @user_domain_projects = services.identity.auth_projects

    # load active project
    if @scoped_project_id
      @active_project = @user_domain_projects.find { |project| project.id == @scoped_project_id }
    end
  end

  ######################## ERROR HANDLING ########################
  # For the case that the dashboard is reconnected to another keystone the keys of
  # friendly id entries are outdated and should be reseted.
  def reset_domain_friendly_id
    #
    # domain = services.admin_identity.domain(@scoped_domain_id)
    # p ":::::::::::::::::::::::DOMAIN"
    # p domain
    # # delete cached frienly ids and reload page.
    # unless domain
    #   services.admin_identity.reset_domain_friendly_id(@scoped_domain_fid)
    #   #services.admin_identity.domain_friendly_id(@scoped_domain_id)
    #   redirect_to url_for(params)
    #   return true
    # else
    #   return false
    # end
    false
  end

  def handle_api_error(exception)
    return if reset_domain_friendly_id

    @errors = DomainModelServiceLayer::ApiErrorHandler.parse(exception)
    render template: 'dashboard/error'
  end

  def handle_auth_error(exception)
    return if reset_domain_friendly_id

    # the user token can be invaild if for example the domain permission has been modified in backend.
    # in this case redirect user to login form
    valid_token = Admin::IdentityService.validate_token(current_user.token) if current_user
    redirect_to_login_form and return unless valid_token

    @errors = {exception.class.name => exception.message}
    render template: 'dashboard/error'
  end

  def authorization_forbidden exception
    @exception = exception
    respond_to do |format|
      format.html { render "dashboard/forbidden", :status => 403 }
      format.js { render "dashboard/forbidden.js" }
    end
  end
  ################################ END ################################
end

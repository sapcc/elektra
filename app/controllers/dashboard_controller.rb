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
                          domain_name: -> c { c.instance_variable_get("@scoped_domain_name") },
                          project: -> c { c.instance_variable_get('@scoped_project_id') },
                          rescope: false # do not rescope after authentication

  # check if user has accepted terms of use. Otherwise it is a new, unboarded user.
  before_filter :check_terms_of_use, except: [:new_user, :new_user_request, :new_user_request_message, :register_user, :register_user_request]
  # rescope token
  before_filter :authentication_rescope_token, except: [:new_user, :new_user_request, :new_user_request_message, :register_user, :register_user_request]
  before_filter :load_user_projects, except: [:new_user, :new_user_request, :register_user, :register_user_request, :new_user_request_message]


  rescue_from "Excon::Errors::Forbidden", with: :handle_api_error
  rescue_from "Excon::Errors::InternalServerError", with: :handle_api_error
  rescue_from "Excon::Errors::Unauthorized", with: :handle_api_error
  rescue_from "MonsoonOpenstackAuth::ApiError", with: :handle_auth_error
  rescue_from "MonsoonOpenstackAuth::Authentication::NotAuthorized", with: :handle_auth_error

  DOMAIN_ACCESS_INQUIRY = 'domain-access'

  def check_terms_of_use
    # Consider that every plugin controller inhertis from dashboard controller
    # and check_terms_of_use method is called on every request.
    # In order to reduce api calls we cache the result of new_user?
    # in the session for one minute.
    if session[:last_request_timestamp].nil? or (session[:last_request_timestamp] < Time.now-1.minute)
      session[:last_request_timestamp] = Time.now
      session[:is_new_dashboard_user] = Admin::OnboardingService.new_user?(current_user) 
    end
    
    #if Admin::OnboardingService.new_user?(current_user)
    if session[:is_new_dashboard_user]
      # new user: user has not a role for requested domain or user has no project yet.
      # save current_url in session
      session[:requested_url] = request.env['REQUEST_URI']
      # redirect to user onboarding page.
      if @scoped_domain_fid == 'sap_default'
        redirect_to "/#{@scoped_domain_fid}/onboarding" and return
      else
        # check for approved inquiry
        if inquiry = services.inquiry.find_by_kind_user_states(DOMAIN_ACCESS_INQUIRY, current_user.id, ['approved'])
          # user has an accepted inquiry for that domain -> onboard user
          params[:terms_of_use] = true
          register_user
          # close inquiry
          services.inquiry.set_state(inquiry.id, :closed, "Domain membership for domain/user #{current_user.id}/#{@scoped_domain_id} granted")
        elsif inquiry = services.inquiry.find_by_kind_user_states(DOMAIN_ACCESS_INQUIRY, current_user.id, ['open'])
          render template: 'dashboard/new_user_request_message'
        elsif inquiry = services.inquiry.find_by_kind_user_states(DOMAIN_ACCESS_INQUIRY, current_user.id, ['rejected'])
          @processors = Admin::IdentityService.list_scope_admins(domain_id: @scoped_domain_id)
          render template: 'dashboard/new_user_reject_message'
        else
          redirect_to "/#{@scoped_domain_fid}/onboarding_request" and return
        end
      end
    end
  end

  # render new user template
  def new_user
  end

  # render new user template
  def new_user_request
  end

  def new_user_request_message
  end

  # onboard new user
  def register_user
    if params[:terms_of_use]
      # user has accepted terms of use -> onboard user
      Admin::OnboardingService.register_user(current_user)
      # redirect to domain path
      if plugin_available?('identity')
        redirect_to plugin('identity').domain_path
      else
        redirect_to main_app.root_path
      end
    else
      render action: :new_user
    end
  end

  # new user request
  def register_user_request
    inquiry = nil

    # checkif there is an request already open (can be resubmitted via browser back)
    if services.inquiry.find_by_kind_user_states(DOMAIN_ACCESS_INQUIRY, current_user.id, ['open'])
      redirect_to :controller=>'dashboard', :action => 'new_user_request_message' and return
    end

    if params[:terms_of_use]
      processors = Admin::IdentityService.list_scope_admins(domain_id: @scoped_domain_id)
      unless processors.blank?
        inquiry = services.inquiry.inquiry_create(
            DOMAIN_ACCESS_INQUIRY,
            "Grant access for user #{current_user.full_name} to Domain #{@scoped_domain_name}",
            current_user,
            current_user.context[:user].to_json,
            processors,
            {},
            @scoped_domain_id
        )
        message = "Error during inquiry creation"
      else
        message = "Couldn't find any administrators for this domain!"
      end
    else
      message = "Please accept the terms of use!"
    end
    
    if message
      flash.now[:error] = message
      render action: :new_user_request
    else
      unless inquiry.errors?
        flash[:notice] = 'Your inquiry was send for further processing'
        redirect_to :controller=>'dashboard', :action => 'new_user_request_message'
      else
        flash.now[:error] = "Your inquiry could not be created because: #{inquiry.errors.full_messages.to_sentence}"
        render action: :new_user_request
      end
    end
  end

  def register_user_approval
    puts "register_user_approval"
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

  def handle_api_error(exception)
    @errors = DomainModelServiceLayer::ApiErrorHandler.parse(exception)
    render template: 'dashboard/error'
  end

  def handle_auth_error(exception)
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

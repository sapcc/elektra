class AuthenticatedUserController < ApplicationController
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
  before_filter :check_terms_of_use
  # rescope token
  before_filter :authentication_rescope_token
                          

  rescue_from "Excon::Errors::Forbidden", with: :handle_api_error
  rescue_from "Excon::Errors::InternalServerError", with: :handle_api_error
  rescue_from "MonsoonOpenstackAuth::ApiError", with: :handle_auth_error
  rescue_from "MonsoonOpenstackAuth::Authentication::NotAuthorized", with: :handle_auth_error

  
  def check_terms_of_use
    if services.admin_identity.new_user?(current_user.id)
      # new user: user has not a role for requested domain or user has no project yet. 
      # save current_url in session  
      session[:requested_url] = request.env['REQUEST_URI']
      # redirect to user onboarding page.
      redirect_to new_user_path and return 
    end
  end
  
  protected

  def handle_api_error(exception)
    @errors = ApiErrorParser.handle(exception)
    render template: 'authenticated_user/error'
  end

  def handle_auth_error(exception)
    # the user token can be invaild if for example the domain permission has been modified in backend.
    # in this case redirect user to login form
    valid_token = services.admin_identity.validate_token(current_user.token) if current_user
    redirect_to_login_form and return unless valid_token
    
    @errors = {exception.class.name => exception.message}
    render template: 'authenticated_user/error'
  end
  
  def authorization_forbidden exception
    @exception = exception
    respond_to do |format|
      format.html { render "authenticated_user/forbidden", :status => 403 } 
      format.js { render "authenticated_user/forbidden.js" }
    end    
  end

end
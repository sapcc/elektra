class AuthenticatedUserController < ApplicationController
  # load region, domain and project if given
  prepend_before_filter do
    # initialize session unless loaded yet
    session[:init] = true unless session.loaded?
  end

  authentication_required domain: -> c { c.instance_variable_get("@domain_id") }, project: -> c { c.instance_variable_get('@project_id') }
  
  before_filter :check_terms_of_use

  rescue_from "Excon::Errors::Forbidden", with: :handle_api_error
  rescue_from "Excon::Errors::InternalServerError", with: :handle_api_error
  rescue_from "MonsoonOpenstackAuth::ApiError", with: :handle_auth_error

  protected

  def handle_api_error(exception)
    @errors = ApiErrorParser.handle(exception)
    render template: 'authenticated_user/error'
  end

  def handle_auth_error(exception)
    @errors = {exception.class.name => exception.message}
    render template: 'authenticated_user/error'
  end

  def check_terms_of_use
    unless services.identity.has_projects?
      # user has no project yet. 
      # We assume that it is a new user -> redirect to terms of use page.
      session[:requested_url] = request.env['REQUEST_URI']
      redirect_to new_user_path
    end
  end
  
  def authorization_forbidden exception
    @exception = exception
    respond_to do |format|
      format.html { render "authenticated_user/forbidden", :status => 403 } 
      format.js { render "authenticated_user/forbidden.js" }
    end    
  end

end
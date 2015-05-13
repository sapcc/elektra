class AuthenticatedUserController < ApplicationController
  # load region, domain and project if given
  before_filter do
    # redirect to the same url with default domain unless domain_id is given
    redirect_to url_for(params.merge(domain_id: MonsoonOpenstackAuth.default_domain.id)) unless params[:domain_id]
    
    @region     ||= MonsoonOpenstackAuth.configuration.default_region
    @domain_id  ||= params[:domain_id]
    @project_id ||= params[:project_id]
  end
   
  authentication_required domain: -> c { c.instance_variable_get("@domain_id") }, project: -> c { c.instance_variable_get('@project_id') }

  include OpenstackServiceProvider::Services  
end
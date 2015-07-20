class AuthenticatedUser::UsersController < AuthenticatedUserController
  skip_before_filter :check_terms_of_use

  def new
    @domain = services.identity.find_domain(@domain_id)
  end

  def create
    if params[:terms_of_use]
      # user has accepted terms of use -> create a sandbox project.
      sandbox = services.admin_identity.create_user_sandbox(@domain_id,current_user)
      # set user default project to sandbox
      services.admin_identity.set_user_default_project(current_user,sandbox.id)
      
      domain = ::Domain.friendly_find_or_create @region, @domain_fid
      project = ::Project.friendly_find_or_create @region, domain, sandbox.id
      
      redirect_to project_path(domain_fid:@domain_fid, id: project.slug)
    else
      render action: :new
    end
  end
end

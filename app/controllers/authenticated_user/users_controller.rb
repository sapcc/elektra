class AuthenticatedUser::UsersController < AuthenticatedUserController
  # do not check terms of use for actions new and create
  skip_before_filter :check_terms_of_use, only: [:new, :create]
  # do not rescope token for actions new and create
  skip_before_filter :authentication_rescope_token, only: [:new, :create]
      
  def new
    @domain = services.admin_identity.domain_find_by_key_or_name(@domain_id)
  end

  def create
    if params[:terms_of_use]
      # user has accepted terms of use -> onboard use!
      
      # add member role to user
      services.admin_identity.create_user_domain_role(current_user.id,'member')
      
      # create a sandbox project.
      sandbox = services.admin_identity.create_user_sandbox(@domain_id,current_user)
      
      # set user default project to sandbox
      services.admin_identity.set_user_default_project(current_user,sandbox.id)
      
      # TODO: remove after refactoring
      domain = ::Domain.friendly_find_or_create @region, @domain_fid
      project = ::Project.friendly_find_or_create @region, domain, sandbox.id
      
      # redirect to sandbox (friendly url)
      redirect_to project_path(domain_fid:@domain_fid, id: project.slug)
    else
      render action: :new
    end
  end
end

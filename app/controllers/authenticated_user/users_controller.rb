class AuthenticatedUser::UsersController < AuthenticatedUserController
  skip_before_filter :check_terms_of_use

  def new
    @domain = services.identity.find_domain(@domain_id)
  end

  def create
    if params[:terms_of_use]
      # user has accepted terms of use -> create a sandbox project.
      sandbox = services.admin_identity.create_user_sandbox(@domain_id,current_user)
      redirect_to session[:requested_url] and return
    end

    render action: :new
  end
end

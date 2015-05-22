class AuthenticatedUser::UsersController < AuthenticatedUserController
  skip_before_filter :check_terms_of_use
  
  def new
  end

  def create
    if params[:terms_of_use]
      technical_user = TechnicalUser.new(auth_session)
      sandbox = technical_user.create_user_sandbox
      redirect_to session[:requested_url] and return
    end
    
    render action: :new
  end
end

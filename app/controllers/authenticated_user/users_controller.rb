class AuthenticatedUser::UsersController < ApplicationController
  skip_before_filter :check_terms_of_use
  
  def terms_of_use
  end

  def register
    if params[:terms_of_use_accepted]
      technical_user = TechnicalUser.new(auth_session)
      sandbox = technical_user.create_user_sandbox
      redirect_to session[:requested_url]
    end
    
    render action: :terms_of_use
  end
end

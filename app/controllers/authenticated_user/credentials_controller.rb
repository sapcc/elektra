class AuthenticatedUser::CredentialsController < AuthenticatedUserController


  def index
    @user_credentials = services.identity.credentials
    @forms_credential = #Forms::Credential.new(services.identity, current_user.id)
  end

  def create
    @credential = Forms::Credential.new(services.identity, current_user.id, params)
    puts "---------------------------------- Credential: #{@credential.inspect}"
    if @credential.save
      flash[:notice] = "Credential created"
    else
      flash[:error] = "Error when creating credential"
    end

    redirect_to :back
  end

end

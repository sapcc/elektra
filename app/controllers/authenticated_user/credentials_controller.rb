class AuthenticatedUser::CredentialsController < AuthenticatedUserController
  before_filter only: [:index,:create] do
    @user_credentials = services.identity.credentials 
  end

  def index
    @forms_credential = services.identity.forms_credential
  end

  def create
    @forms_credential = services.identity.forms_credential
    @forms_credential.attributes = params.fetch(:forms_credential,{}).merge(user_id: current_user.id)

    if @forms_credential.save
      flash[:notice] = "Credential created."
      redirect_to :back
    else
      flash[:error] = @forms_credential.errors.full_messages.to_sentence
      render action: :index
    end
  end

end

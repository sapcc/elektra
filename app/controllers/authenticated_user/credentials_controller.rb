class AuthenticatedUser::CredentialsController < AuthenticatedUserController 
  before_filter only: [:index] do #,:create,:destroy] do
    @user_credentials = services.identity.credentials 
  end

  def index
    
  end
  
  def new
    @forms_credential = services.identity.forms_credential
  end

  def create
    @forms_credential = services.identity.forms_credential
    @forms_credential.attributes = params.fetch(:forms_credential,{}).merge(user_id: current_user.id)

    if @forms_credential.save
      flash[:notice] = "Credential created."
      redirect_to action: :index
    else
      render action: :new, layout: 'modal'
    end
  end
  
  def destroy
    @forms_credential = services.identity.forms_credential(params[:id])
    
    if @forms_credential.destroy
      flash[:notice] = "Credential deleted."
    else
      flash[:notice] = "Could not delete credential"
    end
    redirect_to action: :index
  end

end

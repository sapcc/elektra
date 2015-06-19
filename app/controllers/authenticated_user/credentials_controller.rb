class AuthenticatedUser::CredentialsController < AuthenticatedUserController 
  before_filter only: [:index] do #,:create,:destroy] do
    @user_credentials = services.identity.credentials 
  end

  def index
    @forms_credential = services.identity.forms_credential
  end
  
  def new
  end

  def create
    @forms_credential = services.identity.forms_credential
    @forms_credential.attributes = params.fetch(:forms_credential,{}).merge(user_id: current_user.id)

    respond_to do |format|
      if @forms_credential.save
        flash[:notice] = "Credential created."
        format.js 
      else
        format.js { render action: :new }
      end
    end
  end
  
  def destroy
    @forms_credential = services.identity.forms_credential(params[:id])
    
    @forms_credential.destroy
    #sleep(3)
    #@forms_credential.errors.add(' ','could not delete credential')
    respond_to do |format|
      format.js
    end
  end

end

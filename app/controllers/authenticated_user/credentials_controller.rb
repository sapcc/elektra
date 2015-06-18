class AuthenticatedUser::CredentialsController < AuthenticatedUserController 
  before_filter only: [:index,:create,:destroy] do
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
        format.html { redirect_to :back }
        format.js 
      else
        format.html { 
          flash[:error] = @forms_credential.errors.full_messages.to_sentence 
          render action: :index
        }
        format.js { render action: :new }
      end
    end
  end
  
  def destroy
    @forms_credential = services.identity.forms_credential(params[:id])
    
    if @forms_credential.destroy
      flash[:notice] = "Credential successfully deleted."
      redirect_to credentials_path
    else
      flash[:error] = @forms_credential.errors.full_messages.to_sentence
      render action: :index
    end
  end

end

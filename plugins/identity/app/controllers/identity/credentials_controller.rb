#module Identity
  # we dont use Keystone credential store anymore
  # can be deleted later
  # class CredentialsController < ::DashboardController
  #   def index
  #     @user_credentials = services.identity.credentials
  #   end

  #   def new
  #     @credential = services.identity.new_credential
  #   end

  #   def create
  #     @credential = services.identity.new_credential
  #     @credential.attributes = params.fetch(:os_credential,{}).merge(user_id: current_user.id)

  #     if @credential.save
  #       flash[:notice] = "Credential created."
  #       redirect_to action: :index
  #     else
  #       render action: :new, layout: 'modal'
  #     end
  #   end

  #   def destroy
  #     @credential = services.identity.find_credential(params[:id])

  #     if @credential.destroy
  #       flash[:notice] = "Credential deleted."
  #     else
  #       flash[:notice] = "Could not delete credential."
  #     end
  #     redirect_to action: :index
  #   end
  # end
#end

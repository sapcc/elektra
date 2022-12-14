module Compute
  class KeypairsController < ::DashboardController
    authorization_context "compute"
    authorization_required

    def index
      @user_keypairs = services.compute.keypairs
    end

    def new
      @keypair = services.compute.new_keypair
    end

    def create
      @keypair = services.compute.new_keypair
      @keypair.attributes =
        params.fetch(:keypair, {}).merge(user_id: current_user.id)

      if @keypair.save
        flash[:notice] = "Key pair created."
        audit_logger.info(current_user, "has created", @keypair)
        redirect_to action: :index
      else
        render action: :new, layout: "modal"
      end
    end

    def show
      @keypair = services.compute.find_keypair(params[:id])
    end

    def destroy
      if services.compute.delete_keypair(params[:id])
        audit_logger.info(current_user, "has deleted keypair", params[:id])
        flash[:notice] = "Key pair deleted."
      else
        flash[:notice] = "Could not delete key pair."
      end
      redirect_to action: :index
    end
  end
end

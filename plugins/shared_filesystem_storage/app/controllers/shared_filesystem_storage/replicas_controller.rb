# frozen_string_literal: true

module SharedFilesystemStorage
  # replicas
  class ReplicasController < SharedFilesystemStorage::ApplicationController
    skip_authorization only: %i[promote resync destroy]

    def index
      render json: services.shared_filesystem_storage.replicas_detail 
    end

    def show
      render json: services.shared_filesystem_storage.find_replica(params[:id])
    end

    def update
      replica = services.shared_filesystem_storage
                            .new_replica(replica_params)
      replica.id = params[:id]
      if replica.save
        render json: replica
      else
        render json: { errors: replica.errors }
      end
    end

    def create
      replica = services.shared_filesystem_storage.new_replica(replica_params)

      if replica.save
        render json: replica
      else
        render json: { errors: replica.errors }
      end
    end

    def promote
      replica = services.shared_filesystem_storage.new_replica
      replica.id = params[:id]


      if replica.promote
        render json: replica
      else
        render json: { errors: replica.errors }
      end
    end

    def resync
      replica = services.shared_filesystem_storage.new_replica
      replica.id = params[:id]

      if replica.resync
        render json: replica
      else
        render json: { errors: replica.errors }
      end
    end


    def destroy
      replica = services.shared_filesystem_storage.new_replica
      replica.id = params[:id]

      if replica.destroy
        head :no_content
      else
        render json: { errors: replica.errors }
      end
    end

    protected

    def replica_params
      params.require(:replica).permit(:share_id, :availability_zone, :name)
    end
  end
end

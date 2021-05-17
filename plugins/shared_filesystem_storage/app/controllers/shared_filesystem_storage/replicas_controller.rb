# frozen_string_literal: true

module SharedFilesystemStorage
  # replicas
  class ReplicasController < ApplicationController
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
      puts "####################"
      puts replica_params
      replica = services.shared_filesystem_storage.new_replica(replica_params)
      pp replica

      if replica.save
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

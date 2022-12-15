# frozen_string_literal: true

module SharedFilesystemStorage
  # snapshots
  class SnapshotsController < ApplicationController
    def index
      render json: services.shared_filesystem_storage.snapshots_detail
    end

    def show
      render json: services.shared_filesystem_storage.find_snapshot(params[:id])
    end

    def update
      snapshot =
        services.shared_filesystem_storage.new_snapshot(snapshot_params)
      snapshot.id = params[:id]
      if snapshot.save
        render json: snapshot
      else
        render json: { errors: snapshot.errors }
      end
    end

    def create
      snapshot =
        services.shared_filesystem_storage.new_snapshot(snapshot_params)

      if snapshot.save
        render json: snapshot
      else
        render json: { errors: snapshot.errors }
      end
    end

    def destroy
      snapshot = services.shared_filesystem_storage.new_snapshot
      snapshot.id = params[:id]

      if snapshot.destroy
        head :no_content
      else
        render json: { errors: snapshot.errors }
      end
    end

    protected

    def snapshot_params
      params.require(:snapshot).permit(:share_id, :name, :description)
    end
  end
end

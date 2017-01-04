module SharedFilesystemStorage
  class SnapshotsController < ApplicationController
    def index
      snapshots = services.shared_filesystem_storage.snapshots_detail
      snapshots.each do |snapshot|
        snapshot.permissions = {
          delete: current_user.is_allowed?("shared_filesystem_storage:snapshot_delete"),
          update: current_user.is_allowed?("shared_filesystem_storage:snapshot_update")
        }
      end
      render json: snapshots
    end

    def show
    end

    def update
      snapshot = services.shared_filesystem_storage.new_snapshot(snapshot_params)
      snapshot.id = params[:id]
      if snapshot.save
        snapshot.permissions = {
          delete: current_user.is_allowed?("shared_filesystem_storage:snapshot_delete"),
          update: current_user.is_allowed?("shared_filesystem_storage:snapshot_update")
        }
        render json: snapshot
      else
        render json: { errors: snapshot.errors }
      end
    end

    def create
      snapshot = services.shared_filesystem_storage.new_snapshot(snapshot_params)

      if snapshot.save
        snapshot.permissions = {
          delete: current_user.is_allowed?("shared_filesystem_storage:snapshot_delete"),
          update: current_user.is_allowed?("shared_filesystem_storage:snapshot_update")
        }
        render json: snapshot
      else
        render json: { errors: snapshot.errors }
      end
    end

    def destroy
      snapshot = services.shared_filesystem_storage.new_snapshot
      snapshot.id=params[:id]

      if snapshot.destroy
        head :no_content
      else
        render json: { errors: snapshot.errors }
      end
    end

    protected

    def snapshot_params
      params.require(:snapshot).permit(:share_id,:name,:description)
    end
  end
end

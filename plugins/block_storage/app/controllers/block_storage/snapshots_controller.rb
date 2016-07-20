require_dependency "block_storage/application_controller"

module BlockStorage
  class SnapshotsController < ApplicationController
    before_action :set_snapshot, except: [:index]

    # GET /snapshots
    def index
      if @scoped_project_id
        @snapshots = services.block_storage.snapshots

        # # quota for block_storage is not implemented yet
        # @quota_data = services.resource_management.quota_data([
        #   {service_name: 'block_storage', resource_name: 'snapshots', usage: @snapshots.length}
        #   {service_name: 'block_storage', resource_name: 'capacity'}
        # ])
      end
    end

    # GET /snapshots/1
    def show
    end

    # GET /snapshots/1/edit
    def edit
    end

    # PATCH/PUT /snapshots/1
    def update
      if @snapshot.update(snapshot_params)
        audit_logger.info(current_user, "has updated", @snapshot)
        redirect_to @snapshot, notice: 'Snapshot was successfully updated.'
      else
        @snapshot.errors[:base]
        render :edit
      end
    end

    # DELETE /snapshots/1
    def destroy
      if @snapshot.destroy
        audit_logger.info(current_user, "has deleted", @snapshot)
      else
        flash.now[:error] = "Error during Snapshot deletion!"
      end
      redirect_to snapshots_url, notice: 'Snapshot was successfully deleted.'
    end

    def create_volume
      @volume = services.block_storage_.new_volume
      @volume.name = "vol-" + @snapshot.name
      @volume.description = @snapshot.description
      @volume.size = @snapshot.size
      @volume.snapshot_id = @snapshot.id
      render 'block_storage/volumes/new.html'
    end


    private
    # Use callbacks to share common setup or constraints between actions.
    def set_snapshot
      @snapshot = services.block_storage.get_snapshot(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def snapshot_params
      params[:snapshot]
    end
  end
end

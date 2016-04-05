require_dependency "block_storage/application_controller"

module BlockStorage
  class VolumesController < ApplicationController
    before_action :set_volume, only: [:show, :edit, :update, :destroy, :new_snapshot, :attach, :edit_attach, :detach, :edit_detach]

    # GET /volumes
    def index
      if @scoped_project_id
        @volumes = services.block_storage.volumes
      end
    end

    # GET /volumes/1
    def show
    end

    # GET /volumes/new
    def new
      @volume = services.block_storage_.new_volume
      @availability_zones = services.compute.availability_zones
    end

    # POST /volumes
    def create
      @volume = services.block_storage.new_volume
      @volume.attributes=params[@volume.model_name.param_key]

      if @volume.save
        flash[:notice] = "Volume successfully created."
        redirect_to volumes_path
      else
        @availability_zones = services.compute.availability_zones
        render :new
      end
    end

    # GET /volumes/1/edit
    def edit
    end

    # PATCH/PUT /volumes/1
    def update
      if @volume.update(volume_params)
        redirect_to @volume, notice: 'Volume was successfully updated.'
      else
        render :edit
      end
    end

    # GET /volumes/1/snapshot
    def new_snapshot
      @snapshot = services.block_storage.new_snapshot
      @snapshot.name = "snap-#{@volume.name}"
      @snapshot.description = "snap-#{@volume.description}"
    end

    # POST /volumes/1/snapshot
    def snapshot
      @snapshot = services.block_storage.new_snapshot
      @snapshot.attributes=params[@snapshot.model_name.param_key]
      @snapshot.attributes['volume_id'] = params[:id]

      if @snapshot.save
        flash[:notice] = "Snapshot successfully created."
        redirect_to snapshots_path
      else
        flash[:error] = "Snapshot creation failed!"
        redirect_to volumes_path
      end
    end

    def edit_attach
      @volume_server = VolumeServer.new
      @volume_server.volume = @volume
      @volume_server.servers = services.compute.servers
    end

    def attach
      @volume_server = VolumeServer.new(params['volume_server'])
      @volume_server.volume = @volume
      if @volume_server.valid?
        services.compute.attach_volume(@volume_server.volume.id, @volume_server.server, @volume_server.device)
        flash[:notice] = "Volume successfully attached"
        redirect_to volumes_path
      else
        @volume_server.servers = services.compute.servers
        render :edit_attach
      end
    end

    def edit_detach
      @volume_server = VolumeServer.new
      @volume_server.volume = @volume
      @volume_server.server = @volume.attachments.first
    end

    def detach
      @volume_server = VolumeServer.new
      @volume_server.volume = @volume
      @volume_server.server = @volume.attachments.first
      if services.compute.detach_volume(@volume_server.volume.id, @volume_server.server['server_id'])
        flash[:notice] = "Volume successfully detached"
      else
        flash[:error] = "Error during Volume detach"
      end
      redirect_to volumes_path
    end


    # DELETE /volumes/1
    def destroy
      @volume.destroy
      redirect_to volumes_url, notice: 'Volume was successfully deleted.'
    end

    private
    # Use callbacks to share common setup or constraints between actions.
    def set_volume
      @volume = services.block_storage.get_volume(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def volume_params
      params[:volume]
    end
  end
end

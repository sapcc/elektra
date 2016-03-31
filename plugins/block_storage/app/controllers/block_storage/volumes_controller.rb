require_dependency "block_storage/application_controller"

module BlockStorage
  class VolumesController < ApplicationController
    before_action :set_volume, only: [:show, :edit, :update, :destroy, :new_snapshot, :assign, :attach]

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

    # GET /volumes/1/edit
    def edit
    end

    # POST /volumes
    def create
      @volume = services.block_storage.new_volume
      @volume.attributes=params[@volume.model_name.param_key]

      if @volume.save
        flash[:notice] = "Volume successfully created."
        redirect_to volumes_path
      else
        puts @volume.pretty_attributes
        @availability_zones = services.compute.availability_zones
        render action: :new
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
        puts @snapshot.pretty_attributes
        flash[:error] = "Snapshot creation failed!"
        redirect_to volumes_path
      end
    end

    #
    def assign
      if @volume.attachments.blank?
        attach()
      else
        detach()

      end
    end

    def attach
      @volume_server = VolumeServer.new(params['volume_server'])
      @volume_server.volume = @volume
      if params['volume_server'] && @volume_server.valid?
        #todo attachment
        flash[:notice] = "Volume successfully attached"
        redirect_to volumes_path
      else
        @volume_server.servers = services.compute.servers
        render :attach
      end
    end

    def detach
      @volume_server = VolumeServer.new(params['volume_server'])
      @volume_server.volume = @volume
      @instances = services.compute.find_server(@volume.attachments[0]['server_id'])
      @volume_server.server = @instances[0]
      if params['volume_server']
        #todo detach
        flash[:notice] = "Volume successfully attached"
        redirect_to volumes_path
      else
        render :detach
      end
    end


    # PATCH/PUT /volumes/1
    def update
      if @volume.update(volume_params)
        redirect_to @volume, notice: 'Volume was successfully updated.'
      else
        render :edit
      end
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

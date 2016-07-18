require_dependency "block_storage/application_controller"

module BlockStorage
  class VolumesController < ApplicationController
    before_action :set_volume, only: [:show, :edit, :update, :destroy, :new_snapshot, :attach, :edit_attach, :detach, :edit_detach]
    protect_from_forgery except: [:attach, :detach]

    SERVER_STATES_NEEDED_FOR_ATTACH = ['ACTIVE', 'PAUSED', 'SHUTOFF', 'VERIFY_RESIZE', 'SOFT_DELETED']
    SLEEP = 1

    # GET /volumes
    def index
      @servers = services.compute.servers()
      @action_id = params[:id]
      if @scoped_project_id
        @volumes = services.block_storage.volumes
      end
    end

    # GET /volumes/1
    def show
      @servers = services.compute.servers() if @volume.status == "in-use"
    end

    # GET /volumes/new
    def new
      @volume = services.block_storage_.new_volume
      @availability_zones = services.compute.availability_zones

    end

    # POST /volumes
    def create
      @volume = services.block_storage.new_volume
      @volume.attributes = params[@volume.model_name.param_key].delete_if{ |key,value| value.blank?} # delete blank attributes from hash. If they are passed as empty strings the API doesn't recognize them as blank and throws a fit ...

      if @volume.save
        if @volume.snapshot_id.blank?
          @volume = services.block_storage.get_volume(@volume.id)
          @volume.status = 'creating'
          @target_state = target_state_for_action 'create'
          sleep(SLEEP)
          audit_logger.info(current_user, "has created", @volume)
          render template: 'block_storage/volumes/create.js'
        else
          redirect_to volumes_path
        end
      else
        @availability_zones = services.compute.availability_zones
        @volume.errors[:base] << "Volume creation failed!"
        render :new
      end
    end

    # GET /volumes/1/edit
    def edit
    end

    # PATCH/PUT /volumes/1
    def update
      if @volume.update(volume_params)
        audit_logger.info(current_user, "has updated", @volume)
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
        audit_logger.info(current_user, "has created", @snapshot)
        redirect_to snapshots_path
      else
        set_volume
        flash[:error] = "Snapshot creation failed!"
        render :new_snapshot
      end
    end

    def edit_attach
      @volume_server = VolumeServer.new
      @volume_server.volume = @volume
      @volume_server.servers = services.compute.servers.keep_if { |s| SERVER_STATES_NEEDED_FOR_ATTACH.include? s.status }
    end

    def attach
      @volume_server = VolumeServer.new(params['volume_server'])
      @volume_server.volume = @volume
      @volume_server.device = nil if @volume_server.device.blank?
      if @volume_server.valid?
        begin
          if services.compute.attach_volume(@volume_server.volume.id, @volume_server.server, @volume_server.device)
            @volume.status = 'attaching'
            @target_state = target_state_for_action 'attach'
            sleep(SLEEP)
            audit_logger.info(current_user, "has attached", @volume, "to", @volume_server.server['server_id'])
            render template: 'block_storage/volumes/update_item_with_close.js'
          else
            @volume_server.servers = services.compute.servers
            @volume_server.errors[:base] << "Volume attachment failed!"
            render :edit_attach and return
          end
        rescue Exception => e
          @volume_server.servers = services.compute.servers
          @volume_server.errors[:base] << "Volume attachment failed! #{e.message}"
          render :edit_attach and return
        end
      else
        @volume_server.servers = services.compute.servers
        render :edit_attach and return
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
      begin
        if services.compute.detach_volume(@volume_server.volume.id, @volume_server.server['server_id'])
          @volume.status = 'detaching'
          @target_state = target_state_for_action 'detach'
          sleep(SLEEP)
          audit_logger.info(current_user, "has detached", @volume, "from server", @volume_server.server['server_id'])
          render template: 'block_storage/volumes/update_item_with_close.js'
        else
          flash[:error] = "Error during Volume detach"
          redirect_to volumes_path and return
        end
      rescue Exception => e
        flash[:error] = "Error during Volume detach"
        redirect_to volumes_path and return
      end

    end


    # DELETE /volumes/1
    def destroy
      if @volume.destroy
        audit_logger.info(current_user, "has deleted", @volume)
      end
      @volume.status = 'deleting'
      @target_state = target_state_for_action 'destroy'
      sleep(SLEEP)
      render template: 'block_storage/volumes/update_item.js'
    end

    # update instance table row (ajax call)
    def update_item
      begin
        @volume = services.block_storage.get_volume(params[:id])
        @target_state = params[:target_state]
        respond_to do |format|
          format.js do
            if @volume and @volume.status != @target_state
              @volume.task_state = @target_state
            end
          end
        end
      rescue => e
        return nil
      end
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

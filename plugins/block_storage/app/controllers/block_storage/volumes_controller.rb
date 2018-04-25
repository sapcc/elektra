# frozen_string_literal: true

require_dependency 'block_storage/application_controller'

module BlockStorage
  # volumes controller
  class VolumesController < ApplicationController
    before_action :set_volume, only: %i[
      show edit update destroy new_snapshot attach edit_attach detach
      edit_detach new_status reset_status force_delete
    ]

    protect_from_forgery except: %i[attach detach]

    authorization_context 'block_storage'
    authorization_required

    SERVER_STATES_NEEDED_FOR_ATTACH = %w[ACTIVE PAUSED SHUTOFF
                                         VERIFY_RESIZE SOFT_DELETED'].freeze
    SLEEP = 1

    # GET /volumes
    def index
      @action_id = params[:id]
      return unless  @scoped_project_id

      per_page = (params[:per_page] || 20)
      @volumes = paginatable(per_page: per_page) do |pagination_options|
        services.block_storage.volumes_detail(pagination_options)
      end

      @quota_data = []

      if current_user.is_allowed?('access_to_project')
        @quota_data = services.resource_management.quota_data(
          current_user.domain_id || current_user.project_domain_id,
          current_user.project_id, [
          { service_type: :volumev2, resource_name: :volumes, usage: @volumes.length },
          { service_type: :volumev2, resource_name: :capacity }
        ])
      end

      # this is relevant in case an ajax paginate call is made.
      # in this case we don't render the layout, only the list!
      if request.xhr?
        render partial: 'list', locals: { volumes: @volumes }
      else
        # comon case, render index page with layout
        render action: :index
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
      @volume.attributes = params[@volume.model_name.param_key].to_unsafe_hash.delete_if{ |*,value| value.blank?} # delete blank attributes from hash. If they are passed as empty strings the API doesn't recognize them as blank and throws a fit ...

      if @volume.save
        if @volume.snapshot_id.blank?
          @volume = services.block_storage.find_volume(@volume.id)
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
      if @volume.blank?
        flash.now[:error] = "We couldn't retrieve the volume details. Please try again."
      end
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
      @snapshot = services.block_storage.new_snapshot({force: false})
      @snapshot.attributes = @snapshot.attributes.merge(params[@snapshot.model_name.param_key].to_unsafe_hash)
      @snapshot.volume_id = params[:id]

      if @snapshot.save
        flash[:notice] = "Snapshot successfully created."
        audit_logger.info(current_user, "has created", @snapshot)
        redirect_to volumes_path
      else
        set_volume
        flash[:error] = "Snapshot creation failed!"
        render :new_snapshot
      end
    end

    def edit_attach
      @volume_server = VolumeServer.new
      @volume_server.volume = @volume
      @volume_server.servers = services.compute.servers.keep_if do |s|
        SERVER_STATES_NEEDED_FOR_ATTACH.include?(s.status) and
        s.availability_zone==@volume.availability_zone
      end
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

    def new_status
    end

    def reset_status
      @volume.reset_status(params[:volume])
      # reload volume
      @volume = services.block_storage.find_volume(params[:id])
      if @volume.status == params[:volume][:status]
        audit_logger.info(current_user, "has reset", @volume)
        render template: 'block_storage/volumes/reset_status.js'
      else
        render action: :new_status
      end
    end

    def force_delete
      if @volume.force_delete
        audit_logger.info(current_user, "has deleted (force-delete)", @volume)
      end
      @volume.status = 'deleting'
      @target_state = target_state_for_action 'destroy'
      sleep(SLEEP)
      render template: 'block_storage/volumes/update_item.js'
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
        @volume = services.block_storage.find_volume(params[:id])
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
      @volume = services.block_storage.find_volume(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def volume_params
      params[:volume]
    end
  end
end

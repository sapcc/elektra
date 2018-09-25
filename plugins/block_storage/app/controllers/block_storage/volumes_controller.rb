# frozen_string_literal: true

require_dependency 'block_storage/application_controller'

module BlockStorage
  # volumes controller
  class VolumesController < BlockStorage::ApplicationController
    authorization_context 'block_storage'
    authorization_required

    def index
      per_page = (params[:per_page] || 30).to_i

      options = { sort_key: 'name', sort_dir: 'asc', limit: per_page + 1 }
      options[:marker] = params[:marker] if params[:marker]
      volumes = services.block_storage.volumes_detail(options)

      extend_volume_data(volumes)

      # byebug
      render json: {
        volumes: volumes,
        has_next: volumes.length > per_page
      }
    rescue Elektron::Errors::ApiResponse => e
      render json: { errors: e.message }, status: e.code
    end

    def show
      volume = services.block_storage.find_volume!(params[:id])
      extend_volume_data(volume)

      render json: { volume: volume }
    rescue Elektron::Errors::ApiResponse => e
      render json: { errors: e.message }, status: e.code
    end

    # POST /volumes
    def create
      volume = services.block_storage.new_volume
      volume.attributes = params[:volume]

      if volume.save
        audit_logger.info(current_user, 'has created', volume)
        extend_volume_data(volume)
        render json: volume
      else
        render json: { errors: volume.errors }, status: 422
      end
    rescue Elektron::Errors::ApiResponse => e
      render json: { errors: e.message }, status: e.code
    end

    def update
      volume = services.block_storage.find_volume!(params[:id])

      if volume.update(params[:volume])
        audit_logger.info(current_user, 'has updated', volume)
        extend_volume_data(volume)
        render json: volume
      else
        render json: { errors: volume.errors }, status: 422
      end
    rescue Elektron::Errors::ApiResponse => e
      render json: { errors: e.message }, status: e.code
    end

    # DELETE /volumes/1
    def destroy
      volume = services.block_storage.new_volume
      volume.id = params[:id]

      if volume.destroy
        audit_logger.info(current_user, 'has deleted', volume)
        head 202
      else
        render json: { errors: volume.errors }, status: 422
      end
    rescue Elektron::Errors::ApiResponse => e
      render json: { errors: e.message }, status: e.code
    end

    def attach
      volume = services.block_storage.new_volume
      volume.id = params[:id]

      if volume.attach_to_server(params[:server_id], params[:device])
        audit_logger.info(current_user, "has attached #{volume.id} to #{params[:server_id]}")
        head 202
      else
        render json: { errors: volume.errors }, status: 422
      end
    rescue Elektron::Errors::ApiResponse => e
      render json: { errors: e.message }, status: e.code
    end

    def detach
      volume = services.block_storage.new_volume
      volume.id = params[:id]

      if volume.detach(params[:attachment_id])
        audit_logger.info(current_user, "has detached #{volume.id} #{params[:attachment_id]}")
        head 202
      else
        render json: { errors: volume.errors }, status: 422
      end
    rescue Elektron::Errors::ApiResponse => e
      render json: { errors: e.message }, status: e.code
    end

    def reset_status
      volume = services.block_storage.find_volume(params[:id])

      if volume.reset_status(params[:status])
        audit_logger.info(current_user, 'has reset volume', volume.id)
        render json: volume
      else
        render json: { errors: volume.errors }, status: 422
      end
    rescue Elektron::Errors::ApiResponse => e
      render json: { errors: e.message }, status: e.code
    end

    def force_delete
      volume = services.block_storage.new_volume
      volume.id = params[:id]

      if volume.force_delete
        audit_logger.info(current_user, 'has deleted (force-delete)', volume.id)
        head 202
      else
        render json: { errors: volume.errors }, status: 422
      end
    rescue Elektron::Errors::ApiResponse => e
      render json: { errors: e.message }, status: e.code
    end

    def availability_zones
      render json: { availability_zones: services.compute.availability_zones }
    rescue Elektron::Errors::ApiResponse => e
      render json: { errors: e.message }, status: e.code
    end

    protected
    # this method extends volumes with data from cache
    def extend_volume_data(volumes)
      volumes = [volumes] unless volumes.is_a?(Array)

      user_ids = []
      server_ids = []
      volumes.each do |volume|
        user_ids << volume.user_id
        server_ids << volume.attachments.collect { |a| a['server_id']}
      end

      cached_users = ObjectCache.where(id: user_ids).each_with_object({}) do |u,map|
        map[u.id] = u
      end

      cached_servers = ObjectCache.where(id: server_ids.flatten).each_with_object({}) do |s,map|
        map[s.id] = s
      end

      volumes.each do |volume|
        if cached_users[volume.user_id]
          volume.user_name = "#{cached_users[volume.user_id].payload['description']} (#{cached_users[volume.user_id].name})"
        end
        volume.attachments.each do |attachment|
          if cached_servers[attachment['server_id']]
            attachment['server_name'] = cached_servers[attachment['server_id']].name
          end
        end
      end
    end
  end
end

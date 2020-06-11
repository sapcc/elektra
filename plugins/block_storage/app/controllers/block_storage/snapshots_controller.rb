# frozen_string_literal: true

module BlockStorage
  class SnapshotsController < BlockStorage::ApplicationController
    authorization_context 'block_storage'
    authorization_required

    # GET /snapshots
    def index
      per_page = (params[:per_page] || 20).to_i

      options = { sort: 'id:asc', limit: per_page + 1 }
      options[:marker] = params[:marker] if params[:marker]
      snapshots = services.block_storage.snapshots_detail(options)

      extend_snapshot_data(snapshots)

      # byebug
      render json: {
        snapshots: snapshots,
        has_next: snapshots.length > per_page
      }
    rescue Elektron::Errors::ApiResponse => e
      render json: {
        errors: e.message
      }
    end

    def show
      snapshot = services.block_storage.find_snapshot!(params[:id])
      extend_snapshot_data(snapshot)

      render json: { snapshot: snapshot }
    rescue Elektron::Errors::ApiResponse => e
      render json: { errors: e.message }, status: e.code
    end

    def create
      snapshot = services.block_storage.new_snapshot(
        params[:snapshot].merge(force: false)
      )

      if snapshot.save
        audit_logger.info(current_user, 'has created', snapshot)
        render json: snapshot
      else
        render json: { errors: snapshot.errors }, status: 422
      end
    rescue Elektron::Errors::ApiResponse => e
      render json: { errors: e.message }, status: e.code
    end

    def update
      snapshot = services.block_storage.find_snapshot!(params[:id])

      if snapshot.update(params[:snapshot])
        audit_logger.info(current_user, 'has updated', snapshot)
        extend_snapshot_data(snapshot)
        render json: snapshot
      else
        render json: { errors: snapshot.errors }, status: 422
      end
    rescue Elektron::Errors::ApiResponse => e
      render json: { errors: e.message }, status: e.code
    end

    def destroy
      snapshot = services.block_storage.new_snapshot
      snapshot.id = params[:id]
      if snapshot.destroy
        audit_logger.info(current_user, 'has deleted', snapshot)
        head 202
      else
        render json: { errors: snapshot.errors }, status: 422
      end
    rescue Elektron::Errors::ApiResponse => e
      render json: { errors: e.message }, status: e.code
    end

    def reset_status
      snapshot = services.block_storage.find_snapshot(params[:id])

      if snapshot.reset_status(params[:status])
        audit_logger.info(current_user, 'has reset snapshot', snapshot.id)
        render json: snapshot
      else
        render json: { errors: snapshot.errors }, status: 422
      end
    rescue Elektron::Errors::ApiResponse => e
      render json: { errors: e.message }, status: e.code
    end

    protected
    # this method extends volumes with data from cache
    def extend_snapshot_data(snapshots)
      snapshots = [snapshots] unless snapshots.is_a?(Array)

      volume_ids = snapshots.collect(&:volume_id)

      cached_volumes = ObjectCache.where(id: volume_ids).pluck(:id,:name).each_with_object({}) do |v,map|
        map[v[0]] = v[1]
      end

      snapshots.each do |snapshot|
        if cached_volumes[snapshot.volume_id]
          snapshot.volume_name = cached_volumes[snapshot.volume_id]
        end
      end
    end
  end
end

# frozen_string_literal: true

module Lbaas2
  module Loadbalancers
    class PoolsController < DashboardController

      def index
        per_page = (params[:per_page] || 20).to_i
        pagination_options = { sort_key: 'name', sort_dir: 'asc', limit: per_page + 1 }
        pagination_options[:marker] = params[:marker] if params[:marker]
        pools = services.lbaas2.pools({ loadbalancer_id: params[:loadbalancer_id]}.merge(pagination_options))

        # extend pool data with chached members
        extend_pool_data(pools)

        render json: {
          pools: pools,
          has_next: pools.length > per_page
        }
      rescue Elektron::Errors::ApiResponse => e
        render json: { errors: e.message }, status: e.code
      rescue Exception => e
        render json: { errors: e.message }, status: "500"
      end

      def show
        pool = services.lbaas2.find_pool(params[:id])

        # extend pool data with chached members
        extend_pool_data([pool])

        render json: {
          pool: pool
        }
      rescue Elektron::Errors::ApiResponse => e
        render json: { errors: e.message }, status: e.code
      rescue Exception => e
        render json: { errors: e.message }, status: "500"
      end

      def create
        poolParams = params[:pool]
        newParams = poolParams.merge(session_persistence: composeSessionPersistence(poolParams), project_id: @scoped_project_id, loadbalancer_id: params[:loadbalancer_id])
        pool = services.lbaas2.new_pool(newParams)
        
        if pool.save
          audit_logger.info(current_user, 'has created', pool)
          render json: pool
        else
          render json: {errors: pool.errors}, status: 422
        end
      rescue Elektron::Errors::ApiResponse => e
        render json: { errors: e.message }, status: e.code
      rescue Exception => e
        render json: { errors: e.message }, status: "500"
      end

      def itemsForSelect
        pools = services.lbaas2.pools({ loadbalancer_id: params[:loadbalancer_id], sort_key: 'name', sort_dir: 'asc'})
        select_pools = pools.map {|pool| {"label": "#{pool.name} (#{pool.id})", "value": pool.id}}
        
        render json: { pools: select_pools }
      rescue Elektron::Errors::ApiResponse => e
        render json: { errors: e.message }, status: e.code
      rescue Exception => e
        render json: { errors: e.message }, status: "500"
      end
      
      protected

      def composeSessionPersistence(poolParams)
        session_persistence = {}
        persistenceType = poolParams['session_persistence_type']
        unless persistenceType.blank?
          session_persistence[:type] = persistenceType
          if persistenceType == "APP_COOKIE"
            session_persistence[:cookie_name] = poolParams['session_persistence_cookie_name']
          end
        end
        session_persistence
      end

      def extend_pool_data(pools)
        pools.each do |pool|
          # get cached members
          pool.members = [] if pool.members.blank?
          pool.cached_members = ObjectCache.where(id: pool.members.map{|l| l[:id]}).each_with_object({}) do |l,map|
            map[l[:id]] = l
          end
          
          # get chached listeners
          pool.listeners = [] if pool.listeners.blank?
          pool.cached_listeners = ObjectCache.where(id: pool.listeners.map{|l| l[:id]}).each_with_object({}) do |l,map|
            map[l[:id]] = l
          end

        end
      end

    end
  end
end
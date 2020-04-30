# frozen_string_literal: true

module Lbaas2
  module Loadbalancers
    class ListenersController < DashboardController

      def index
        per_page = (params[:per_page] || 20).to_i
        pagination_options = { sort_key: 'name', sort_dir: 'asc', limit: per_page + 1 }
        pagination_options[:marker] = params[:marker] if params[:marker]
        listeners = services.lbaas2.listeners({ loadbalancer_id: params[:loadbalancer_id]}.merge(pagination_options))
        # extend listener data with chached data
        extend_listener_data(listeners)

        render json: {
          listeners: listeners,
          has_next: listeners.length > per_page
        }
      rescue Elektron::Errors::ApiResponse => e
        render json: { errors: e.message }, status: e.code
      rescue Exception => e
        render json: { errors: e.message }, status: "500"
      end

      def show
        listener = services.lbaas2.find_listener(params[:id])
        # extend listener data with chached data
        extend_listener_data([listener])
        render json: {
          listener: listener
        }
      rescue Elektron::Errors::ApiResponse => e
        render json: { errors: e.message }, status: e.code
      rescue Exception => e
        render json: { errors: e.message }, status: "500"
      end   

      def destroy
        listener = services.lbaas2.new_listener
        listener.id = params[:id]
  
        if listener.destroy
          audit_logger.info(current_user, 'has deleted', listener)
          head 202
        else  
          render json: { errors: listener.errors }, status: 422
        end
      rescue Elektron::Errors::ApiResponse => e
        render json: { errors: e.message }, status: e.code
      rescue Exception => e
        render json: { errors: e.message }, status: "500"
      end

      def pools
        pools = services.lbaas2.pools({ loadbalancer_id: params[:loadbalancer_id], sort_key: 'name', sort_dir: 'asc'})
        select_pools = pools.map {|pool| {"label": "#{pool.name} (#{pool.id})", "value": pool.id}}

        render json: { pools: select_pools }
      rescue Elektron::Errors::ApiResponse => e
        render json: { errors: e.message }, status: e.code
      rescue Exception => e
        render json: { errors: e.message }, status: "500"
      end

      protected

      def extend_listener_data(listeners)
        listeners.each do |listener|
          # get cached listeners
          listener.l7policies = [] if listener.l7policies.blank?
          listener.cached_l7policies = ObjectCache.where(id: listener.l7policies.map{|l| l[:id]}).each_with_object({}) do |l,map|
            map[l[:id]] = l
          end
    
        end
      end

    end
  end
end
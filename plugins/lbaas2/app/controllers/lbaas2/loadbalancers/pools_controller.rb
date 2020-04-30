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

      protected

      def extend_pool_data(pools)
        pools.each do |pool|
          # get cached members
          pool.members = [] if pool.members.blank?
          pool.cached_members = ObjectCache.where(id: pool.members.map{|l| l[:id]}).each_with_object({}) do |l,map|
            map[l[:id]] = l
          end
    
        end
      end

    end
  end
end
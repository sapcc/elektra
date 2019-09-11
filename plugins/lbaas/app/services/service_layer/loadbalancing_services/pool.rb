# frozen_string_literal: true

module ServiceLayer
  module LoadbalancingServices
    # This module implements Openstack Designate Pool API
    module Pool
      def pool_map
        @pool_map ||= class_map_proc(::Loadbalancing::Pool)
      end

      def pools(filter = {})
        elektron_lb.get('pools', filter).map_to('body.pools', &pool_map)
      end

      def find_pool!(id)
        elektron_lb.get("pools/#{id}").map_to('body.pool', &pool_map)
      end

      def find_pool(id)
        find_pool!(id)
      rescue Elektron::Errors::ApiResponse
        nil
      end

      def new_pool(attributes = {})
        pool_map.call(attributes)
      end

      ################# INTERFACE METHODS ######################
      def create_pool(params)
        elektron_lb.post('pools') do
          { pool: params }
        end.body['pool']
      end

      def update_pool(id, params)
        elektron_lb.put("pools/#{id}") do
          { pool: params }
        end.body['pool']
      end

      def delete_pool(id)
        elektron_lb.delete("pools/#{id}")
      end
    end
  end
end

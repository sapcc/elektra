module ServiceLayer
  module Lbaas2Services
    module PoolV2
      def pool_map
        @pool_map ||= class_map_proc(::Lbaas2::Pool)
      end

      def pools(filter = {})
        elektron_lb2.get("pools", filter).map_to("body.pools", &pool_map)
      end

      def find_pool(id)
        elektron_lb2.get("pools/#{id}").map_to("body.pool", &pool_map)
      end

      def new_pool(attributes = {})
        pool_map.call(attributes)
      end

      ################# INTERFACE METHODS ######################
      def create_pool(params)
        elektron_lb2.post("pools") { { pool: params } }.body["pool"]
      end

      def update_pool(id, params)
        elektron_lb2.put("pools/#{id}") { { pool: params } }.body["pool"]
      end

      def delete_pool(id)
        elektron_lb2.delete("pools/#{id}")
      end
    end
  end
end

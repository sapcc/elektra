module ServiceLayer
  module Lbaas2Services
    module PoolV2

      def pool_map
        @pool_map ||= class_map_proc(::Lbaas2::Pool)
      end

      def pools(filter = {})
        elektron_lb2.get('pools', filter).map_to(
          'body.pools', &pool_map
        )
      end

    end
  end
end
# frozen_string_literal: true

module ServiceLayer
  module Lbaas2Services
    module Loadbalancer
      def loadbalancer_map
        @loadbalancer_map ||= class_map_proc(::Lbaas::Loadbalancer)
      end

      def loadbalancers(filter = {})
        elektron_lb.get('loadbalancers', filter).map_to(
          'body.loadbalancers', &loadbalancer_map
        )
      end
    end
  end
end

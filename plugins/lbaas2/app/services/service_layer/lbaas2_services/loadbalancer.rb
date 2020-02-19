# frozen_string_literal: true

module ServiceLayer
  module Lbaas2Services
    module Loadbalancer
      def loadbalancer_map
        @loadbalancer_map ||= class_map_proc(::Lbaas::Loadbalancer)
      end

      def lb_status_map
        @lb_status_map ||= class_map_proc(::Lbaas::Statuses)
      end

      def loadbalancers(filter = {})
        elektron_lb.get('loadbalancers', filter).map_to(
          'body.loadbalancers', &loadbalancer_map
        )
      end

      def loadbalancer_statuses!(id)
        elektron_lb.get("loadbalancers/#{id}/statuses").map_to(
          'body.statuses', &lb_status_map
        )
      end

      def loadbalancer_statuses(id)
        loadbalancer_statuses!(id)
      rescue Elektron::Errors::ApiResponse
        nil
      end

    end
  end
end

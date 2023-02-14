# frozen_string_literal: true

module ServiceLayer
  module Lbaas2Services
    module LoadbalancerV2
      def loadbalancer_map
        @loadbalancer_map ||= class_map_proc(::Lbaas2::Loadbalancer)
      end

      def lb_status_map
        @lb_status_map ||= class_map_proc(::Lbaas2::Statuses)
      end

      # API call without model mapping
      def loadbalancer_device(id)
        elektron_amphorae.get(id).body.fetch("amphora", {})
      end

      def loadbalancers(filter = {})
        elektron_lb2.get("loadbalancers", filter).map_to(
          "body.loadbalancers",
          &loadbalancer_map
        )
      end

      def new_loadbalancer(attributes = {})
        loadbalancer_map.call(attributes)
      end

      def loadbalancer_statuses(id)
        elektron_lb2.get("loadbalancers/#{id}/statuses").map_to(
          "body.statuses",
          &lb_status_map
        )
      end

      def find_loadbalancer(id)
        elektron_lb2.get("loadbalancers/#{id}").map_to(
          "body.loadbalancer",
          &loadbalancer_map
        )
      end

      ################# INTERFACE METHODS ######################
      def create_loadbalancer(attributes)
        elektron_lb2
          .post("loadbalancers") { { loadbalancer: attributes } }
          .body[
          "loadbalancer"
        ]
      end

      def update_loadbalancer(id, attributes)
        elektron_lb2
          .put("loadbalancers/#{id}") { { loadbalancer: attributes } }
          .body[
          "loadbalancer"
        ]
      end

      def delete_loadbalancer(id)
        elektron_lb2.delete("loadbalancers/#{id}?cascade=true")
      end
    end
  end
end

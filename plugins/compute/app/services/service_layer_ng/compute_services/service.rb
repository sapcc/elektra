# frozen_string_literal: true

module ServiceLayerNg
  module ComputeServices
    # This module implements Openstack Domain API
    module Service
      def services(filter = {})
        api.compute.list_compute_services(filter).map_to(Compute::Service)
      end

      def disable_service_reason(host, name, disabled_reason)
        api.compute.log_disabled_compute_service_information(
          'host' => host,
          'binary' => name,
          'disabled_reason' => disabled_reason
        )
      end

      def disable_service(host, name)
        api.compute.disable_scheduling_for_a_compute_service(
          'host'   => host, 'binary' => name
        )
      end

      def enable_service(host, name)
        api.compute.enable_scheduling_for_a_compute_service(
          'host'   => host, 'binary' => name
        )
      end
    end
  end
end

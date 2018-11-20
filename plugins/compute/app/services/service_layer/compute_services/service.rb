# frozen_string_literal: true

module ServiceLayer
  module ComputeServices
    # This module implements Openstack Domain API
    module Service
      def service_map
        @service_map ||= class_map_proc(Compute::Service)
      end

      def services(filter = {})
        elektron_compute.get('os-services', filter).map_to(
          'body.services', &service_map
        )
      end

      def new_service(attributes = {})
        service_map.call(attributes)
      end

      def disable_service_reason(host, name, disabled_reason)
        elektron_compute.put('os-services/disable-log-reason') do
          {
            'host' => host,
            'binary' => name,
            'disabled_reason' => disabled_reason
          }
        end
      end

      def disable_service(host, name)
        elektron_compute.put('os-services/disable') do
          { 'host' => host, 'binary' => name }
        end
      end

      def enable_service(host, name)
        elektron_compute.put('os-services/enable') do
          { 'host' => host, 'binary' => name }
        end
      end
    end
  end
end

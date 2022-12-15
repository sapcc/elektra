# frozen_string_literal: true

module ServiceLayer
  module ComputeServices
    # This module implements Openstack Compute Hypervisor API
    module Hypervisor
      def hypervisor_map
        @hypervisor_map ||= class_map_proc(Compute::Hypervisor)
      end

      def hypervisors(filter = {})
        elektron_compute.get("os-hypervisors/detail", filter).map_to(
          "body.hypervisors",
          &hypervisor_map
        )
      end

      def find_hypervisor(id)
        return nil if id.blank?
        elektron_compute.get("os-hypervisors/#{id}").map_to(
          "body.hypervisor",
          &hypervisor_map
        )
      end

      def hypervisor_servers(hypervisor_hostname_pattern)
        data =
          elektron_compute.get(
            "os-hypervisors/#{hypervisor_hostname_pattern}/servers",
          ).body[
            "hypervisors"
          ]
        data.each_with_object([]) do |hypervisor, results|
          next unless hypervisor["servers"]
          hypervisor["servers"].each do |server|
            results << Compute::HypervisorServer.new(self, server)
          end
        end
      end
    end
  end
end

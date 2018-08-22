# frozen_string_literal: true

module ServiceLayer
  module NetworkingServices
    # Implements Openstack Port
    module Asr
      # Returns a json string showing any diffs between device configuration
      # and that expected by Neutron.
      def asr_router(router_id)
        elektron_networking.get("/asr1k/routers/#{router_id}").body
      end

      # Attempts to sync the neutron config to the devices.
      def asr_sync_router(router_id)
        elektron_networking.put("/asr1k/routers/#{router_id}").body
      end

      # Removes the router config from the devices. Use with caution!
      def asr_delete_router(router_id)
        elektron_networking.delete("/asr1k/routers/#{router_id}").body
      end

      # Returns a json string showing ASR1K specific configuration stored
      # in Neutron, important when debugging L2 specific issues.
      def ars_config(router_id)
        elektron_networking.get("/asr1k/config/#{router_id}").body
      end

      # Creates ASR1K specific Neutron configuration. Use with caution!
      def ars_create_config(router_id)
        elektron_networking.put("/asr1k/config/#{router_id}").body
      end

      # Returns a json string showing configuration regarded as redundant
      # based on a check against Neutron. It uses pattern matching to identify
      # potential candidates and cannot be guarenteed 100% accurate.
      def asr_orphaned_config(agent_host)
        elektron_networking.get("/asr1k/orphans/#{agent_host}").body
      end

      # Removes any orphaned configuration from the devices.
      # ** Please check** all configuration returned by the GET method is
      # indeed managed by the ASR1K driver before executing this method.
      def asr_delete_orphaned_config(agent_host)
        elektron_networking.delete("/asr1k/orphans/#{agent_host}").body
      end

      # Show L3 interface information and packet statistics for the the
      # Neutron router's interfaces on the devices.
      def asr_interface_statistics(router_id)
        elektron_networking.get("/asr1k/interface-statistics/#{router_id}").body
      end

      # Returns a json string showing device configuration on the agent.
      def asr_device(agent_host)
        elektron_networking.get("/asr1k/devices/#{agent_host}").body
      end

      # Use with a JSON body in format {[device1_id]}:[enable][disable],[device2_id]}:[enable][disable]
      # to enable or disable a specific device.
      # Disabled means config will not be applied to the device
      def asr_update_device(agent_host, data)
        elektron_networking.put("/asr1k/devices/#{agent_host}") do
          data
        end.body
      end
    end
  end
end

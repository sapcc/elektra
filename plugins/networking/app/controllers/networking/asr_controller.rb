# frozen_string_literal: true

module Networking
  # Implements Router actions
  class AsrController < DashboardController
    # GET	/asr1k/routers/[router-id]	Returns a json string showing any diffs between device configuration and that expected by Neutron.
    # PUT	/asr1k/routers/[router-id]	Attempts to sync the neutron config to the devices
    # DELETE	/asr1k/routers/[router-id]	Removes the router config from the devices. Use with caution
    # GET	/asr1k/config/[router-id]	Returns a json string showing ASR1K specific configuration stored in Neutron, important when debugging L2 specific issues
    # PUT	/asr1k/config/[router-id]	Creates ASR1K specific Neutron configuration. Use with caution
    # GET	/asr1k/orphans/[agent-host]	Returns a json string showing configuration regarded as redundant based on a check against Neutron. It uses pattern matching to identify potential candidates and cannot be guarenteed 100% accurate.
    # DELETE	/asr1k/orphans/[agent-host]	Removes any orphaned configuration from the devices. ** Please check** all configuration returned by the GET method is indeed managed by the ASR1K driver before executing this method
    # GET	/asr1k/interface-statistics/[router-id]	Show L3 interface information and packet statistics for the the Neutron router's interfaces on the devices.
    # GET	/asr1k/devices/[agent-host]	Returns a json string showing device configuration on the agent.
    # PUT	/asr1k/device/[agent-host]	Use with a JSON body in format {[device1_id]}:[enable][disable],[device2_id]}:[enable][disable] to enable or disable a specific device. Disabled means config will not be applied to the device

    # Returns a json string showing any diffs between device configuration
    # and that expected by Neutron.

    def show_router
      render json: {
               router: services.networking.asr_router(params[:router_id]),
             }
    rescue Elektron::Errors::ApiResponse => e
      render json: { error: e.message }
    end

    def sync_router
      render json: {
               router: services.networking.asr_sync_router(params[:router_id]),
             }
    rescue Elektron::Errors::ApiResponse => e
      render json: { error: e.message }
    end

    def show_config
      render json: {
               config: services.networking.ars_config(params[:router_id]),
             }
    rescue Elektron::Errors::ApiResponse => e
      render json: { error: e.message }
    end

    def show_statistics
      render json: {
               statistics:
                 services.networking.asr_interface_statistics(
                   params[:router_id],
                 ),
             }
    rescue Elektron::Errors::ApiResponse => e
      render json: { error: e.message }
    end
  end
end

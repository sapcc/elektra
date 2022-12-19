# frozen_string_literal: true

module Networking
  # Implements Openstack DHCP Agent
  class DhcpAgent < Core::ServiceLayer::Model
    def status
      alive == true ? "alive" : "dead"
    end

    def admin_state
      admin_state_up ? "UP" : "DOWN"
    end

    def destroy
      before_destroy
      rescue_api_errors { @service.delete_dhcp_agent(id, network_id) }
    end
  end
end

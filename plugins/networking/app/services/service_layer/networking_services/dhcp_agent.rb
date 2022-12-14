# frozen_string_literal: true

module ServiceLayer
  module NetworkingServices
    # Implements Openstack DHCP Agents
    module DhcpAgent
      def dhcp_agent_map
        @dhcp_agent_map ||= class_map_proc(Networking::DhcpAgent)
      end

      def dhcp_agents
        elektron_networking.get("agents", agent_type: "DHCP agent").map_to(
          "body.agents",
          &dhcp_agent_map
        )
      end

      def network_dhcp_agents(network_id)
        elektron_networking.get("networks/#{network_id}/dhcp-agents").map_to(
          "body.agents",
          &dhcp_agent_map
        )
      end

      def new_dhcp_agent(attributes = {})
        dhcp_agent_map.call(attributes)
      end

      def delete_dhcp_agent(agent_id, network_id)
        elektron_networking.delete(
          "agents/#{agent_id}/dhcp-networks/#{network_id}",
        )
      end

      def create_dhcp_agent(attributes)
        # byebug
        create_attributes = attributes.deep_dup
        agent_id = create_attributes.delete(:agent_id)
        begin
          elektron_networking.post("agents/#{agent_id}/dhcp-networks") do
            create_attributes
          end
        rescue Elektron::Errors::ApiResponse => e
          # neutron returns invalid json response 'null'
          raise e unless e.message.match?("unexpected token at 'null'")
        end
        attributes[:id] = agent_id
        # we assume creation worked and return input attributes
        attributes
      end
    end
  end
end

# frozen_string_literal: true

module ServiceLayerNg
  module NetworkingServices
    # Implements Openstack DHCP Agents
    module DhcpAgent
      def dhcp_agents
        api.networking.list_agents(agent_type: 'DHCP agent')
           .map_to(Networking::DhcpAgent)
      end

      def network_dhcp_agents(network_id)
        api.networking.list_network_dhcp_agents(network_id)
           .map_to(Networking::DhcpAgent)
      end

      def new_dhcp_agent(attributes = {})
        map_to(Networking::DhcpAgent, attributes)
      end

      def delete_dhcp_agent(agent_id, network_id)
        api.networking.delete_agent_dhcp_network(agent_id, network_id)
      end

      def create_dhcp_agent(attributes)
        create_attributes = attributes.deep_dup
        agent_id = create_attributes.delete(:agent_id)
        begin
          api.networking.create_agent_dhcp_network(agent_id, create_attributes)
        rescue Core::Api::ResponseError => e
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

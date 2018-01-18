# frozen_string_literal: true

module ServiceLayerNg
  module NetworkingServices
    # Implements Openstack Network
    module Network
      def network_map
        @network_map ||= class_map_proc(Networking::Network)
      end

      def network_ip_availability_map
        @network_ip_availability_map ||= class_map_proc(Networking::NetworkIpAvailability)
      end

      def new_network_wizard(attributes = {})
        map_to(Networking::NetworkWizard, attributes)
      end

      def network_ip_availability(network_id)
        elektron_networking.get(
          "network-ip-availabilities/#{network_id}"
        ).map_to('body.network_ip_availability', &network_ip_availability_map)
      end

      def network_ip_availabilities
        api.networking.list_network_ip_availability
           .map_to(Networking::NetworkIpAvailability)
      end

      def networks(filter = {})
        elektron_networking.get('networks', filter).map_to(
          'body.networks', &network_map
        )
      end

      def project_networks(project_id, filter = {})
        networks = elektron_networking.get('networks', filter).body['networks']
        networks.each_with_object([]) do |n, array|
          if n['shared'] == true || n['tenant_id'] == project_id
            array << network_map.call(n)
          end
        end
      end

      def find_network!(id)
        return nil unless id
        elektron_networking.get("networks/#{id}").map_to(
          'body.network', &network_map
        )
      end

      def find_network(id)
        find_network!(id)
      rescue Elektron::Errors::ApiResponse
        nil
      end

      def cached_network(id)
        network_data = Rails.cache.fetch("network_#{id}", expires_in: 2.hours) do
          begin
            api.networking.show_network_details(id).data
          rescue => e
            nil
          end
        end
        return nil unless network_data
        map_to(Networking::Network, network_data)
      end

      def domain_floatingip_network(domain_name)
        # ccadmin, cc3test -> FloatingIP-internal-monsoon3
        domain_name = 'monsoon3' if %w[ccadmin cc3test].include?(domain_name)

        name_candidates = ["FloatingIP-external-#{domain_name}-04",
                           "FloatingIP-external-#{domain_name}-03",
                           "FloatingIP-external-#{domain_name}-02",
                           "FloatingIP-external-#{domain_name}-01",
                           "FloatingIP-external-#{domain_name}",
                           'Converged Cloud External']
        name_candidates.each do |name|
          network = api.networking.list_networks(
            'router:external' => true, 'name' => name
          ).map_to(Networking::Network).first
          return network if network
        end
        nil
      end

      def new_network(attributes = {})
        map_to(Networking::Network, attributes)
      end

      ############## Model Interface ##############
      def create_network(attributes)
        api.networking.create_network(network: attributes).data
      end

      def update_network(id, attributes)
        api.networking.update_network(id, network: attributes).data
      end

      def delete_network(id)
        api.networking.delete_network(id)
      end
    end
  end
end

# frozen_string_literal: true

module ServiceLayerNg
  # Implements Openstack Network
  module Network
    def network_ip_availability(network_id)
      api.networking.show_network_ip_availability(network_id)
         .map_to(Networking::NetworkIpAvailabilityNg)
    end

    def network_ip_availabilities
      api.networking.list_network_ip_availability
         .map_to(Networking::NetworkIpAvailabilityNg)
    end

    def networks(filter = {})
      api.networking.list_networks(filter).map_to(Networking::NetworkNg)
    end

    def project_networks(project_id, filter = nil)
      api.networking.networks(filter).data.each_with_object([]) do |n, array|
        if n['shared'] == true || n['tenant_id'] == project_id
          array << map_to(Networking::NetworkNg, n)
        end
      end
    end

    def find_network!(id)
      return nil unless id
      api.networking.show_network_details(id).map_to(Networking::NetworkNg)
    end

    def find_network(id)
      find_network!(id)
    rescue
      nil
    end

    def domain_floatingip_network(domain_name)
      # ccadmin, cc3test -> FloatingIP-internal-monsoon3
      domain_name = 'monsoon3' if %w[ccadmin cc3test].include?(domain_name)

      name_candidates = ["FloatingIP-external-#{domain_name}",
                         "FloatingIP-internal-#{domain_name}",
                         'Converged Cloud External']
      name_candidates.each do |name|
        network = api.networking.list_networks(
          'router:external' => true, 'name' => name
        ).map_to(Networking::NetworkNg).first
        return network if network
      end
      nil
    end

    def new_network(attributes = {})
      map_to(Networking::NetworkNg, attributes)
    end
  end
end

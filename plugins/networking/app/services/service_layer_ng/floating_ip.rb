# frozen_string_literal: true

module ServiceLayerNg
  # Implements Openstack FloatingIp
  module FloatingIp
    def project_floating_ips(project_id, filter = {})
      api.networking
         .list_floating_ips(filter)
         .data
         .each_with_object([]) do |ip, array|
           if ip['tenant_id'] == project_id
             array << map_to(Networking::FloatingIp, fip)
           end
         end
    end

    def attach_floatingip(floating_ip_id, port_id)
      api.networking.update_floating_ip(
        floating_ip_id, floatingip: { port_id: port_id }
      ).map_to(Networking::FloatingIp)
    end

    def detach_floatingip(floating_ip_id)
      api.networking.update_floating_ip(
        floating_ip_id, floatingip: { port_id: nil }
      ).map_to(Networking::FloatingIp)
    end

    def new_floating_ip(attributes = {})
      map_to(Networking::FloatingIp, attributes)
    end

    def find_floating_ip!(id)
      return nil unless id
      api.networking.show_floating_ip_details(id)
         .map_to(Networking::FloatingIp)
    end

    def find_floating_ip(id)
      find_floating_ip!(id)
    rescue
      nil
    end

    def delete_floating_ip(id)
      api.networking.delete_floating_ip(id)
    end
  end
end

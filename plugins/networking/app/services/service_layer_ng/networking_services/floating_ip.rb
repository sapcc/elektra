# frozen_string_literal: true

module ServiceLayerNg
  module NetworkingServices
    # Implements Openstack FloatingIp
    module FloatingIp
      def project_floating_ips(project_id, filter = {})
        api.networking
           .list_floating_ips(filter)
           .data('floatingips')
           .each_with_object([]) do |fip, array|
             if fip['tenant_id'] == project_id
               array << map_to(Networking::FloatingIp, fip)
             end
           end
      end

      # def attach_floatingip(floating_ip_id, port_id, fixed_ip_address = nil)
      #   params = { port_id: port_id }
      #   params[:fixed_ip_address] = fixed_ip_address if fixed_ip_address
      #
      #   api.networking.update_floating_ip(floating_ip_id, floatingip: params)
      #      .map_to(Networking::FloatingIp)
      # end

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

      ################## Model Interface ##################
      def create_floating_ip(attributes)
        api.networking.create_floating_ip(floatingip: attributes).data
      end

      def update_floating_ip(id, attributes)
        api.networking.update_floating_ip(id, floatingip: attributes).data
      end

      def delete_floating_ip(id)
        api.networking.delete_floating_ip(id)
      end
    end
  end
end

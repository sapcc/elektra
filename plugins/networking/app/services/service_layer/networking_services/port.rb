# frozen_string_literal: true

module ServiceLayer
  module NetworkingServices
    # Implements Openstack Port
    module Port
      def port_map
        @port_map ||= class_map_proc(Networking::Port)
      end

      def ports(filter = {})
        elektron_networking.get("ports", filter).map_to("body.ports", &port_map)
      end

      def new_port(attributes = {})
        port_map.call(attributes)
      end

      def find_port!(id)
        return nil unless id
        elektron_networking.get("ports/#{id}").map_to("body.port", &port_map)
      end

      def find_port(id)
        find_port!(id)
      rescue Elektron::Errors::ApiResponse
        nil
      end

      def fixed_ip_ports(filter = {})
        @fixed_ip_ports ||=
          ports({ name: Networking::Port::FIXED_IP_PORT_NAME }.merge(filter))
        # @fixed_ip_ports ||= ports({status: 'DOWN'}.merge(filter)).select do |port|
        #   port.device_id.blank? &&
        #   port.device_owner.blank? &&
        #   !port.fixed_ips.blank?
        # end
      end

      ################### Model Interface #############
      def create_port(attributes)
        elektron_networking.post("ports") { { "port" => attributes } }.body[
          "port"
        ]
      end

      def update_port(id, attributes)
        elektron_networking
          .put("ports/#{id}") { { "port" => attributes } }
          .body[
          "port"
        ]
      end

      def delete_port(id)
        elektron_networking.delete("ports/#{id}")
      end
    end
  end
end

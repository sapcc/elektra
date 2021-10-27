# frozen_string_literal: true

module ServiceLayer
  module NetworkingServices
    # Implements Openstack Network
    module BgpVpn

      def bgp_vpns(filter = {})
        return 200, elektron_networking.get('bgpvpn/bgpvpns', filter).body
      rescue Elektron::Errors::ApiResponse => e
        return e.code, e.messages.join(', ')
      end

      def router_associations(bgpvpn_id)
        # byebug
        return 200, elektron_networking.get("bgpvpn/bgpvpns/#{bgpvpn_id}/router_associations").body
      rescue Elektron::Errors::ApiResponse => e
        return e.code, e.messages.join(', ')
      end

      def create_router_association(bgpvpn_id,router_id)
        return 201, elektron_networking.post("bgpvpn/bgpvpns/#{bgpvpn_id}/router_associations") do 
          {
            "router_association": {
              "router_id": router_id
            }
          }
        end.body
      rescue Elektron::Errors::ApiResponse => e
        return e.code, e.messages.join(', ')
      end

      def delete_router_association(bgpvpn_id,router_association_id)
        elektron_networking.delete(
          "bgpvpn/bgpvpns/#{bgpvpn_id}/router_associations/#{router_association_id}"
        )
        return 204
      rescue Elektron::Errors::ApiResponse => e
        return e.code, e.messages.join(', ')
      end

     
      # def new_network(attributes = {})
      #   network_map.call(attributes)
      # end

      # ############## Model Interface ##############
      # def create_network(attributes)
      #   elektron_networking.post('networks') do
      #     { 'network' => attributes }
      #   end.body['network']
      # end

      # def update_network(id, attributes)
      #   elektron_networking.put("networks/#{id}") do
      #     { 'network' => attributes }
      #   end.body['network']
      # end

      # def delete_network(id)
      #   elektron_networking.delete("networks/#{id}")
      # end
    end
  end
end

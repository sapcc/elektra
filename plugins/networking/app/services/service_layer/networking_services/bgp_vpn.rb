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

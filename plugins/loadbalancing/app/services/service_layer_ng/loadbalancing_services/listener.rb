# frozen_string_literal: true

module ServiceLayerNg
  module LoadbalancingServices
    # This module implements Openstack Designate Pool API
    module Listener

      def listeners(filter={})
        driver.map_to(Loadbalancing::Listener).listeners(filter)
      end

      def find_listener(listener_id)
        driver.map_to(Loadbalancing::Listener).get_listener(listener_id)
      end

      def new_listener(attributes={})
        Loadbalancing::Listener.new(driver, attributes)
      end

      ################# INTERFACE METHODS ######################
      def create_listener(params)
        elektron_shares.post('security-services') do
          { security_service: params }
        end.body['security_service']
      end

      def update_listener(id, params)
        elektron_shares.put("security-services/#{id}") do
          { security_service: params }
        end.body['security_service']
      end

      def delete_listener(id)
        elektron_shares.delete("security-services/#{id}")
      end
    end
  end
end

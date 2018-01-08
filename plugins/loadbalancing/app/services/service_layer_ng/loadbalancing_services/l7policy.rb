# frozen_string_literal: true

module ServiceLayerNg
  module LoadbalancingServices
    # This module implements Openstack Designate Pool API
    module L7Policy

      def l7policies(filter={})
        driver.map_to(Loadbalancing::L7policy).l7policies(filter)
      end

      def find_l7policy(l7policy_id)
        driver.map_to(Loadbalancing::L7policy).get_l7policy(l7policy_id)
      end

      def new_l7policy(attributes={})
        Loadbalancing::L7policy.new(driver, attributes)
      end

      ################# INTERFACE METHODS ######################
      def create_l7policy(params)
        elektron_shares.post('security-services') do
          { security_service: params }
        end.body['security_service']
      end

      def update_l7policy(id, params)
        elektron_shares.put("security-services/#{id}") do
          { security_service: params }
        end.body['security_service']
      end

      def delete_l7policy(id)
        elektron_shares.delete("security-services/#{id}")
      end
    end
  end
end

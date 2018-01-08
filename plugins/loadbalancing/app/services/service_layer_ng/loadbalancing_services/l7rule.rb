# frozen_string_literal: true

module ServiceLayerNg
  module LoadbalancingServices
    # This module implements Openstack Designate Pool API
    module L7Rule
      def l7rules(l7policy_id, filter={})
        driver.map_to(Loadbalancing::L7rule).l7rules(l7policy_id, filter)
      end

      def find_l7rule(l7policy_id, l7rule_id)
        driver.map_to(Loadbalancing::L7rule).get_l7rule(l7policy_id, l7rule_id)
      end

      def new_l7rule(attributes={})
        Loadbalancing::L7rule.new(driver, attributes)
      end

      ################# INTERFACE METHODS ######################
      def create_l7rule(params)
        elektron_shares.post('security-services') do
          { security_service: params }
        end.body['security_service']
      end

      def delete_l7rule(l7policy_id, l7rule_id)
        driver.map_to(Loadbalancing::L7rule).delete_l7rule(l7policy_id, l7rule_id)
      end

      def update_l7rule(l7policy_id, l7rule_id, attributes={})
        driver.map_to(Loadbalancing::L7rule).update_l7rule(l7policy_id, l7rule_id, attributes)
      end
    end
  end
end

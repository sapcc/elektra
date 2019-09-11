# frozen_string_literal: true

module ServiceLayer
  module LoadbalancingServices
    # This module implements Openstack Designate Pool API
    module L7rule
      def l7rule_map
        @l7rule_map ||= class_map_proc(::Loadbalancing::L7rule)
      end

      def l7rules(l7policy_id, filter = {})
        elektron_lb.get("l7policies/#{l7policy_id}/rules", filter).map_to(
          'body.rules', &l7rule_map
        )
      end

      def find_l7rule!(l7policy_id, l7rule_id)
        elektron_lb.get("l7policies/#{l7policy_id}/rules/#{l7rule_id}").map_to(
          'body.rule', &l7rule_map
        )
      end

      def find_l7rule(l7policy_id, l7rule_id)
        find_l7rule!(l7policy_id, l7rule_id)
      rescue Elektron::Errors::ApiResponse
        nil
      end

      def new_l7rule(attributes = {})
        l7rule_map.call(attributes)
      end

      ################# INTERFACE METHODS ######################
      def create_l7rule(l7policy_id, params)
        elektron_lb.post("l7policies/#{l7policy_id}/rules") do
          { rule: params }
        end.body['rule']
      end

      def update_l7rule(l7policy_id, l7rule_id, params)
        elektron_lb.put("l7policies/#{l7policy_id}/rules/#{l7rule_id}") do
          { rule: params }
        end.body['rule']
      end

      def delete_l7rule(l7policy_id, l7rule_id)
        elektron_lb.delete("l7policies/#{l7policy_id}/rules/#{l7rule_id}")
      end
    end
  end
end

module ServiceLayer
  module Lbaas2Services
    module L7rule

      def l7rule_map
        @l7rule_map ||= class_map_proc(::Lbaas2::L7rule)
      end

      def l7rules(l7policy_id, filter = {})
        elektron_lb2.get("l7policies/#{l7policy_id}/rules", filter).map_to(
          'body.rules', &l7rule_map
        )
      end

      def new_l7rule(attributes = {})
        l7rule_map.call(attributes)
      end

      def find_l7rule(l7policy_id, l7rule_id)
        elektron_lb2.get("l7policies/#{l7policy_id}/rules/#{l7rule_id}").map_to(
          'body.rule', &l7rule_map
        )
      end

      ################# INTERFACE METHODS ######################
      def create_l7rule(l7policy_id, attributes)
        elektron_lb2.post("l7policies/#{l7policy_id}/rules") do
          { rule: attributes }
        end.body['rule']
      end

    end
  end
end

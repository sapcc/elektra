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

    end
  end
end

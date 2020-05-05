module ServiceLayer
  module Lbaas2Services
    module L7policyV2

      def l7policy_map
        @l7policy_map ||= class_map_proc(::Lbaas2::L7policy)
      end

      def l7policies(filter = {})
        elektron_lb2.get('l7policies', filter).map_to(
          'body.l7policies', &l7policy_map
        )
      end

      def find_l7policy(l7policy_id)
        elektron_lb2.get("l7policies/#{l7policy_id}").map_to(
          'body.l7policy', &l7policy_map
        )
      end
      
      def new_l7policy(attributes = {})
        l7policy_map.call(attributes)
      end

      ################# INTERFACE METHODS ######################
      def create_l7policy(attributes)
        elektron_lb2.post('l7policies') do
          { l7policy: attributes }
        end.body['l7policy']
      end

    end
  end
end
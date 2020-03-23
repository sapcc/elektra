module ServiceLayer
  module Lbaas2Services
    module L7policy

      def l7policy_map
        @l7policy_map ||= class_map_proc(::Lbaas2::L7policy)
      end

      def l7policies(filter = {})
        elektron_lb2.get('l7policies', filter).map_to(
          'body.l7policies', &l7policy_map
        )
      end

    end
  end
end
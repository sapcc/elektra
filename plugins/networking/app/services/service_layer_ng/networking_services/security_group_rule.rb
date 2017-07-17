# frozen_string_literal: true

module ServiceLayerNg
  module NetworkingServices
    # Implements Openstack SecurityGroup
    module SecurityGroupRule
      def security_group_rules(filter = {})
        api.networking.list_security_group_rules(filter)
           .map_to(Networking::SecurityGroupRule)
      end

      def find_security_group_rule!(id)
        return nil unless id
        api.networking.show_security_group_rule(id)
           .map_to(Networking::SecurityGroupRule)
      end

      def find_security_group_rule(id)
        find_security_group_rule!(id)
      rescue
        nil
      end

      def new_security_group_rule(attributes = {})
        map_to(Networking::SecurityGroupRule, attributes)
      end

      ########### Model Interface ###################
      def create_security_group_rule(attributes)
        api.networking
           .create_security_group_rule(security_group_rule: attributes).data
      end

      def delete_security_group_rule(id)
        api.networking.delete_security_group_rule(id)
      end
    end
  end
end

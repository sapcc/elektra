# frozen_string_literal: true

module ServiceLayer
  module NetworkingServices
    # Implements Openstack SecurityGroupRule
    module SecurityGroupRule
      def security_group_rule_map
        @security_group_rule_map ||=
          class_map_proc(Networking::SecurityGroupRule)
      end

      def security_group_rules(filter = {})
        elektron_networking.get("security-group-rules", filter).map_to(
          "body.security_group_rules",
          &security_group_rule_map
        )
      end

      def find_security_group_rule!(id)
        return nil unless id
        elektron_networking.get("security-group-rules/#{id}").map_to(
          "body.security_group_rule",
          &security_group_rule_map
        )
      end

      def find_security_group_rule(id)
        find_security_group_rule!(id)
      rescue Elektron::Errors::ApiResponse
        nil
      end

      def new_security_group_rule(attributes = {})
        security_group_rule_map.call(attributes)
      end

      ########### Model Interface ###################
      def create_security_group_rule(attributes)
        elektron_networking
          .post("security-group-rules") { { security_group_rule: attributes } }
          .body[
          "security_group_rule"
        ]
      end

      def delete_security_group_rule(id)
        elektron_networking.delete("security-group-rules/#{id}")
      end
    end
  end
end

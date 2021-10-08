# frozen_string_literal: true

module Compute
  # Represents the Server Security Group
  class ServerSecurityGroup < Core::ServiceLayer::Model

    def security_group_rules
      read("rules")
    end
    
    def rule_objects
      attribute_to_object('rules', Networking::SecurityGroupRule)
    end
  end
end

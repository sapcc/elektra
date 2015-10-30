module Compute
  class SecurityGroup < DomainModelServiceLayer::Model
    def security_group_rules
      @security_group_rules ||= (attribute_to_object(:security_group_rules,Compute::SecurityGroupRule) || [])
    end
  end
end
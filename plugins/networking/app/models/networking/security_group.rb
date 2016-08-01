module Networking
  class SecurityGroup < Core::ServiceLayer::Model
    validates :name, presence: true
    
    def rule_objects
      attribute_to_object("security_group_rules",Networking::SecurityGroupRule)
    end
  end
end

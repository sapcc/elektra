module Networking
  class SecurityGroupRule < Core::ServiceLayer::Model
    RULE_TYPES = HashWithIndifferentAccess.new(YAML.load(File.open("#{::Core::PluginsManager.plugin('networking').path}/config/security_group_rule_types.yml", 'r')))

    DESCRIPTIONS = RULE_TYPES[:descriptions]
    PREDEFINED_RULE_TYPES = RULE_TYPES[:predefined_types]
    PROTOCOLS = RULE_TYPES[:protocols]

    PROTOCOL_LABELS = PROTOCOLS.inject({}){|hash,(protocol_name,label)| hash[label]=protocol_name; hash}
    TYPE_LABELS = PREDEFINED_RULE_TYPES.inject({}){|hash,(rule_name,rule)| hash[rule['label']]=rule_name; hash}

    PORT_RANGE_RULE = PREDEFINED_RULE_TYPES.inject({}){|hash,(rule_name,rule)| hash[rule['port_range'].to_s]= rule; hash }

    def port_range
      if port_range_min.blank? && port_range_max.blank?
        nil
      elsif port_range_min.blank?
        port_range_max
      elsif port_range_max.blank?
        port_range_min
      else
        "#{port_range_min}-#{port_range_max}"
      end
    end

    def display_port
      port = if port_range_min.blank? && port_range_max.blank?
               nil
             elsif port_range_min.blank? && !port_range_max.blank?
               port_range_max
             elsif !port_range_min.blank? && port_range_max.blank?
               port_range_min
             elsif port_range_min == port_range_max
               port_range_min
             else
               "#{port_range_min}-#{port_range_max}"
             end

      return 'Any' unless port

      rule = PORT_RANGE_RULE[port.to_s]
      port = port.to_s
      port += " (#{rule['label']})" if rule
      port
    end

    def to_s(security_groups=[])
      result = "ALLOW #{self.ethertype} #{self.display_port} #{self.direction=='ingress' ? 'from' : 'to'} "
      result += if self.remote_ip_prefix.blank? and self.remote_group_id.blank?
        if (self.ethertype || '').downcase=='ipv4'
          '0.0.0.0/0'
        else
          '::/0'
        end
      elsif self.remote_ip_prefix.blank?
        sg = catch :found do
          security_groups.each do |sg|
            throw :found, sg if sg.id==self.remote_group_id
          end
          nil
        end
        sg.nil? ? self.remote_group_id : sg.name
      else
        self.remote_ip_prefix
      end

      result
    end
  end
end

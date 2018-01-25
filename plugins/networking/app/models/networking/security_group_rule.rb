# frozen_string_literal: true

module Networking
  # Represents the Openstack Security Group Rule
  class SecurityGroupRule < Core::ServiceLayer::Model
    RULE_TYPES = HashWithIndifferentAccess.new(
      YAML.safe_load(
        File.open(
          "#{::Core::PluginsManager.plugin('networking').path}/config/security_group_rule_types.yml",
          'r'
        )
      )
    )

    DESCRIPTIONS = RULE_TYPES[:descriptions]
    PREDEFINED_RULE_TYPES = RULE_TYPES[:predefined_types]
    PROTOCOLS = RULE_TYPES[:protocols]

    PROTOCOL_LABELS = PROTOCOLS
                      .each_with_object({}) do |(protocol_name, label), hash|
                        hash[label] = protocol_name
                      end
    TYPE_LABELS = PREDEFINED_RULE_TYPES
                  .each_with_object({}) do |(rule_name, rule), hash|
                    hash[rule['label']] = rule_name
                  end

    PORT_RANGE_RULE = PREDEFINED_RULE_TYPES
                      .each_with_object({}) do |(_rule_name, rule), hash|
                        hash[rule['port_range'].to_s] = rule
                      end

    validate :ip_prefix

    def ip_prefix
      IPAddr.new remote_ip_prefix unless remote_ip_prefix.blank?
    rescue => _e
      errors.add(:remote_ip_prefix, 'Please enter a valid IP Address')
    end

    def display_protocol
      protocol || 'Any'
    end

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

    def to_s(security_groups = [])
      result = "ALLOW #{ethertype} #{display_protocol} #{display_port} #{direction == 'ingress' ? 'from' : 'to'} "
      result += if remote_ip_prefix.blank? && remote_group_id.blank?
                  if (ethertype || '').downcase == 'ipv4'
                    '0.0.0.0/0'
                  else
                    '::/0'
                  end
                elsif remote_ip_prefix.blank?
                  sg = catch :found do
                    security_groups.each do |sg|
                      throw :found, sg if sg.id == remote_group_id
                    end
                    nil
                  end
                  sg.nil? ? remote_group_id : sg.name
                else
                  remote_ip_prefix
                end

      result
    end
  end
end

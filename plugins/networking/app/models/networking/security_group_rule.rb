# frozen_string_literal: true

module Networking
  # Represents the Openstack Security Group Rule
  class SecurityGroupRule < Core::ServiceLayer::Model
    validate :ip_prefix

    def ip_prefix
      IPAddr.new remote_ip_prefix unless remote_ip_prefix.blank?
    rescue StandardError => _e
      errors.add(:remote_ip_prefix, 'Please enter a valid IP Address')
    end

    def attributes_for_create
      {
        'direction'         => read('direction'),
        'port_range_min'    => read('port_range_min'),
        'ethertype'         => read('ethertype'),
        'port_range_max'    => read('port_range_max'),
        'protocol'          => read('protocol'),
        'remote_group_id'   => read('remote_group_id'),
        'security_group_id' => read('security_group_id'),
        'remote_ip_prefix' => read('remote_ip_prefix'),
        'description'       => read('description')
      }.delete_if { |_k, v| v.blank? }
    end

    def to_s(security_groups = [])
      port = if port_range_min.blank? && port_range_max.blank?
         'any port'
       elsif port_range_min.blank? && !port_range_max.blank?
         port_range_max
       elsif !port_range_min.blank? && port_range_max.blank?
         port_range_min
       elsif port_range_min == port_range_max
         port_range_min
       else
         "#{port_range_min}-#{port_range_max}"
       end

      result = "ALLOW #{ethertype} #{protocol || 'any protocol'} #{port} #{direction == 'ingress' ? 'from' : 'to'} "
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

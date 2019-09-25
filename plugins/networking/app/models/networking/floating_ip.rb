# frozen_string_literal: true

require 'ipaddr'

module Networking
  # Represents the Openstack Floating IP
  class FloatingIp < Core::ServiceLayer::Model

    def attributes_for_create
      {
        'floating_network_id' => read('floating_network_id'),
        'description'         => read('description'),
        'subnet_id'           => read('floating_subnet_id'),
        'tenant_id'           => read('tenant_id'),
        'project_id'          => read('project_id'),
        'fixed_ip_address'    => read('fixed_ip_address'), # Optional
        'floating_ip_address' => read('floating_ip_address'), # Optional
        'port_id'             => read('port_id'), # Optional
        'dns_domain'          => read('dns_domain'), # Optional
        'dns_name'            => read('dns_name') # Optional
      }.delete_if { |_k, v| v.blank? }
    end

    def attributes_for_update
      {
        'description'       => read('description').to_s,
        'port_id'           => read('port_id'),
        'fixed_ip_address'  => read('fixed_ip_address')
      }
    end

    def subnet_object
      @subnet_object if @subnet_object
      @subnet_object ||= @service
                         .cached_network_subnets(floating_network_id)
                         .find do |subnet|
                           IPAddr.new(subnet.cidr).include?(floating_ip_address)
                         end
    end

    def detach
      self.port_id = nil
      self.fixed_ip_address = nil
      save
    end
  end
end

# frozen_string_literal: true

require 'ipaddr'

module Networking
  # Represents the Openstack Floating IP
  class FloatingIp < Core::ServiceLayerNg::Model
    def attributes_for_create
      {
        'floating_network_id' => read('floating_network_id'),
        'subnet_id'           => read('floating_subnet_id')
      }.delete_if { |_k, v| v.blank? }
    end

    def subnet_object
      @subnet_object if @subnet_object
      @subnet_object ||= @service
                         .cached_network_subnets(floating_network_id)
                         .find do |subnet|
                           IPAddr.new(subnet.cidr).include?(floating_ip_address)
                         end
    end
  end
end

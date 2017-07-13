# frozen_string_literal: true

module Networking
  # represents the Openstack Router
  class Router < Core::ServiceLayerNg::Model
    validates :name, presence: { message: 'Please provide a name' }

    attr_accessor :internal_subnets
    validates :internal_subnets, presence: {
      message: 'Please select at least one subnet from the private network subnets'
    }

    def ip_subnet_objects
      return @ip_subnet_objects if @ip_subnet_objects
      return unless external_gateway_info
      return unless external_gateway_info['external_fixed_ips']

      ip_infos = external_gateway_info['external_fixed_ips']
      ip_infos = [ip_infos] unless ip_infos.is_a?(Array)

      @ip_subnet_objects = ip_infos.each_with_object({}) do |ip_info, hash|
        hash[ip_info['ip_address']] = @service
                                      .cached_subnet(ip_info['subnet_id'])
      end
    end

    def network_object
      return unless external_gateway_info
      return unless external_gateway_info['network_id']
      @service.cached_network(external_gateway_info['network_id'])
    end

    def external_ip
      external_gateway_info['external_fixed_ips'].collect do |ips|
        ips['ip_address']
      end.join(', ')
    rescue
      nil
    end

    def external_gateway_info
      read('external_gateway_info') || {}
    end
  end
end

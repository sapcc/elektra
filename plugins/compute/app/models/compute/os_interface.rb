# frozen_string_literal: true

module Compute
  # Represents the Server Interface
  class OsInterface < Core::ServiceLayerNg::Model
    def attributes_for_create
      attrs = {
        'net_id'      => read('net_id'),
        'port_id'     => read('port_id')
      }.delete_if { |_k, v| v.blank? }

      if read('fixed_ips')
        ips = read('fixed_ips')
        ips = [ips] unless ips.is_a?(Array)
        attrs['fixed_ips'] = {
          'ip_address' => ips.collect { |ip| { 'ip_address' => ip } }
        }
      end
      attrs
    end

    # msp to driver create method
    def perform_service_create(create_attributes)
      @service.create_os_interface(server_id, create_attributes)
    end

    def perform_service_delete(_id)
      @service.delete_os_interface(server_id, port_id)
    end
  end
end

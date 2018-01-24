# frozen_string_literal: true

module Compute
  # Represents the Server Interface
  class OsInterface < Core::ServiceLayer::Model
    def attributes_for_create
      attrs = {
        'net_id'      => read('net_id'),
        'port_id'     => read('port_id')
      }.delete_if { |_k, v| v.blank? }

      if read('fixed_ips') && read('fixed_ips').length.positive?
        ips = read('fixed_ips').keep_if { |ip| ip && !ip['ip_address'].blank? }
        attrs['fixed_ips'] = ips unless ips.empty?
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

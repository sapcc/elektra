# frozen_string_literal: true

module Compute
  # Represents the Server Interface
  class OsInterface < Core::ServiceLayerNg::Model
    def attributes_for_create
      attrs = {
        'net_id'      => read('net_id'),
        'port_id'     => read('port_id'),
        'fixed_ips'   => read('fixed_ips')
      }.delete_if { |_k, v| v.blank? }
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

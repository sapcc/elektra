module Compute
  class OsInterface < Core::ServiceLayer::Model
    def attributes_for_create
      {
        "fixed_ips"   => read("fixed_ips"),
        "net_id"      => read("net_id"),
        "port_id"     => read("port_id")
      }.delete_if { |k, v| v.blank? }
    end

    # msp to driver create method
    def perform_driver_create(create_attributes)
      @driver.create_os_interface(server_id, create_attributes)
    end

    def perform_driver_delete(id)
      @driver.delete_os_interface(server_id, port_id)
    end
  end
end

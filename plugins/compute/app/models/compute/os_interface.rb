# frozen_string_literal: true

module Compute
  # Represents the Server Interface
  class OsInterface < Core::ServiceLayer::Model
    validates :net_id, presence: { message: "Please select a network" }
    validates :subnet_id, presence: { message: "Please select a subnet" }

    def attributes_for_create
      attrs = {}
      attrs["net_id"] = read("net_id") if read("port_id").blank?
      attrs["port_id"] = read("port_id") unless read("port_id").blank?

      if read("fixed_ips") && read("fixed_ips").length.positive? &&
           read("port_id").blank?
        ips = read("fixed_ips").keep_if { |ip| ip && !ip["ip_address"].blank? }
        attrs["fixed_ips"] = ips unless ips.empty?
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

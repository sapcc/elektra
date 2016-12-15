module Networking
  class FloatingIp < Core::ServiceLayer::Model

    def attributes_for_create
      {
        "floating_network_id"              => read("floating_network_id"),
        "subnet_id"                        => read("floating_subnet_id")
      }.delete_if { |k, v| v.blank? }
    end

  end
end

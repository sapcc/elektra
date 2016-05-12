module Networking
  class Port < Core::ServiceLayer::Model
    def network_object
      @network_object ||= @driver.map_to(::Networking::Network).get_network(self.network_id)
    end
  end
end
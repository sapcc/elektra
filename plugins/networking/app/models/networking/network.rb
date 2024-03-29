module Networking
  class Network < Core::ServiceLayer::Model
    validates :name, presence: true
    @highest_asr_agents_count = 0

    def external
      read("router:external")
    end

    def external?
      external == true
    end

    def shared?
      shared == true
    end

    def provider_network_type
      read("provider:network_type")
    end

    def provider_physical_network
      read("provider:physical_network")
    end

    def provider_segmentation_id
      read("provider:segmentation_id")
    end

    def subnet_objects
      @subnet_objects ||= @service.subnets(network_id: id)
    end

    def port_objects
      @port_objects ||= @service.ports(network_id: id)
    end

    def set_highest_asr_agents_count(highest_asr_agents_count)
      self.highest_asr_agents_count = highest_asr_agents_count
    end
  end
end

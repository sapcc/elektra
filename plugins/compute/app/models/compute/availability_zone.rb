module Compute
  class AvailabilityZone < Core::ServiceLayerNg::Model
    def id
      read("zoneName")
    end
    
    def name
      read("zoneName")
    end
  end
end
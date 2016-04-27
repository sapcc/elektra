module Compute
  class AvailabilityZone < Core::ServiceLayer::Model
    def id
      read("zoneName")
    end
    
    def name
      read("zoneName")
    end
  end
end
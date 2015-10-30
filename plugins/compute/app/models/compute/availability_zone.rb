module Compute
  class AvailabilityZone < DomainModelServiceLayer::Model
    def id
      read("zoneName")
    end
    
    def name
      read("zoneLabel")
    end
  end
end
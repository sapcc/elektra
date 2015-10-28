module Compute
  class AvailabilityZone < DomainModelServiceLayer::BaseObject
    def id
      read("zoneName")
    end
    
    def name
      read("zoneLabel")
    end
  end
end
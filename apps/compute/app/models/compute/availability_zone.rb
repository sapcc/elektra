module Compute
  class AvailabilityZone < OpenstackServiceProvider::BaseObject
    def id
      read("zoneName")
    end
    
    def name
      read("zoneLabel")
    end
  end
end
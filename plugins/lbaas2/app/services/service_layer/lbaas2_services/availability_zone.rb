module ServiceLayer
  module Lbaas2Services
    module AvailabilityZone      

      def availability_zones(filter = {})
        elektron_lb2.get("availabilityzones", filter).body.fetch("availability_zones",[]) 
      end

    end
  end
end

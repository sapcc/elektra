# frozen_string_literal: true

module Compute
  # Represents Openstack AvailabilityZone
  class AvailabilityZone < Core::ServiceLayerNg::Model
    def id
      read('zoneName')
    end

    def name
      read('zoneName')
    end
  end
end

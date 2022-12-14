module Compute
  class HostAggregatesController < Compute::ApplicationController
    authorization_context "compute"
    authorization_required

    def index
      @host_aggregates = services.compute.host_aggregates
    end
  end
end

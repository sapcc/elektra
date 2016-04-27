module Networking
  class FloatingIpsController < DashboardController
    def index
      @floating_ips = services.networking.project_floating_ips(@scoped_project_id)
    end
  end
end

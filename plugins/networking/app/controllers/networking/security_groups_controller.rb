module Networking
  class SecurityGroupsController < DashboardController
    def index
      @security_groups = services.networking.project_security_groups(@scoped_project_id)
    end
  end
end

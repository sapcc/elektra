module Networking
  class SecurityGroupsController < DashboardController
    def index
      @security_groups = services.networking.project_security_groups(@scoped_project_id)
      
      @quota_data = services.resource_management.quota_data([
        {service_name: 'networking', resource_name: 'security_groups', usage: @security_groups.length},
        {service_name: 'networking', resource_name: 'security_group_rules'}
      ])
    end
  end
end

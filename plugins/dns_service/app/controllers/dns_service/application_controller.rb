module DnsService
  class ApplicationController < ::DashboardController
    include CreateZonesHelper
    before_action :all_projects

    private

    def load_zone(id)
      @zone = services.dns_service.find_zone(id, @admin_option)
      @impersonate_option =
        if @all_projects && @scoped_project_id != @zone.project_id
          { project_id: @zone.project_id }
        else
          {}
        end
    end

    def all_projects
      @all_projects = current_user.is_allowed?("dns_service:all_projects")
      @admin_option = @all_projects ? { all_projects: true } : {}
    end
  end
end

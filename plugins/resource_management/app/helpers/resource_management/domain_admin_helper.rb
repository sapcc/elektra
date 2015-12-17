module ResourceManagement
  module DomainAdminHelper

    # Depending on the criticality of the given project Resource record, return
    # either "danger", "warning", or "" (uncritical).
    def warning_level_for_project(project_resource)
      # unlimited current quota is always critical
      current = project_resource.current_quota
      return "danger" if current < 0

      # warn if current_quota is not equal to approved_quota
      # (above = very bad, below = asking for trouble)
      approved = project_resource.approved_quota
      return approved < current ? 'danger'
           : approved > current ? 'warning'
           :                      ''
    end

  end
end

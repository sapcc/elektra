module ResourceManagement
  module CloudAdminHelper

    # Depending on the criticality of the given domain Resource record, return
    # either "danger", "warning", or "" (uncritical).
    #
    # `usage_sum` and `project_quota_sum` are aggregates over the project
    # resources for this domain.
    def warning_level_for_domain(domain_resource, usage_sum, project_quota_sum)
      approved = domain_resource.approved_quota

      # usage exceeding approved quota is critical
      return 'danger'  if approved < usage_sum
      # project quotas exceeding domain quota is dubious
      return 'warning' if approved < project_quota_sum

      return ''
    end

  end
end

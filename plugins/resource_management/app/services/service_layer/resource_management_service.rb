module ServiceLayer

  class ResourceManagementService < DomainModelServiceLayer::Service

    def driver
      @driver ||= ResourceManagement::Driver::Fog.new({
        auth_url: self.auth_url,
        region: self.region,
        token: self.token,
        domain_id: self.domain_id,
        project_id: self.project_id,
      })
    end

    # Discover existing domains, then:
    # 1. Cleanup Resource objects for deleted domains from local DB.
    # 2. Use sync_projects() to create and/or update Resource objects for all
    #    projects in all known domains.
    def sync_domains(options={})
      # check which domains exist in the DB and in Keystone
      all_domain_ids = driver.enumerate_domains
      Rails.logger.info "ResourceManagement > sync_domains: domains in Keystone are: #{all_domain_ids.join(' ')}"
      db_domain_ids = ResourceManagement::Resource.pluck('DISTINCT domain_id')

      # drop Resource objects for deleted domains
      old_domain_ids = db_domain_ids - all_domain_ids
      Rails.logger.info "ResourceManagement > sync_domains: cleaning up deleted domains: #{old_domain_ids.join(' ')}"
      ResourceManagement::Resource.where(domain_id: old_domain_ids).destroy_all()

      # call sync_projects on all existing domains
      all_domain_ids.each { |domain_id| sync_projects(domain_id, options) }
    end

    # Discover existing projects in a domain, then:
    # 1. Cleanup Resource objects for deleted projects from local DB.
    # 2. Create Resource objects for new projects in local DB.
    def sync_projects(domain_id, options={})
      # check which projects exist in the DB and in Keystone
      all_project_ids = driver.enumerate_projects(domain_id)
      Rails.logger.info "ResourceManagement > sync_projects(#{domain_id}): projects in Keystone are: #{all_project_ids.join(' ')}"
      db_project_ids = ResourceManagement::Resource.where(domain_id: domain_id).pluck('DISTINCT project_id')

      # drop Resource objects for deleted projects
      old_project_ids = db_project_ids - all_project_ids
      Rails.logger.info "ResourceManagement > sync_projects(#{domain_id}): cleaning up deleted projects: #{old_project_ids.join(' ')}"
      ResourceManagement::Resource.where(domain_id: domain_id, project_id: old_project_ids).destroy_all()

      # initialize Resource objects for new domains (by recursing into sync_project)
      # or refresh all projects when options[:sync_all_projects] is given
      project_ids_to_update = options[:sync_all_projects] ? all_project_ids : (all_project_ids - db_project_ids)
      project_ids_to_update.each { |project_id| sync_project(domain_id, project_id) }
    end

    # Update Resource entries for the given project with fresh current_quota
    # and usage values (and create missing Resource entries as necessary).
    def sync_project(domain_id, project_id)
      Rails.logger.info "ResourceManagement > sync_project(#{domain_id}, #{project_id})"

      # fetch current quotas and usage for this project from all services
      enabled_services = ResourceManagement::Resource::KNOWN_SERVICES.select { |srv| srv[:enabled] }.map { |srv| srv[:service] }
      actual_quota = {}
      actual_usage = {}
      enabled_services.each do |service|
        actual_quota[service] = driver.query_project_quota(domain_id, project_id, service)
        actual_usage[service] = driver.query_project_usage(domain_id, project_id, service)
      end

      # write values into database
      enabled_resources = ResourceManagement::Resource::KNOWN_RESOURCES.select { |res| enabled_services.include?(res[:service]) }
      enabled_resources.each do |resource|
        this_actual_quota = actual_quota[ resource[:service] ][ resource[:name] ] || 0
        this_actual_usage = actual_usage[ resource[:service] ][ resource[:name] ] || 0

        # create new Resource entry if necessary
        object = ResourceManagement::Resource.where(
          cluster_id: nil, # TODO: take cluster assignment into account for brokered services
          domain_id:  domain_id,
          project_id: project_id,
          service:    resource[:service],
          name:       resource[:name],
        ).first_or_create(
          usage:          this_actual_usage,
          current_quota:  this_actual_quota,
          approved_quota: 0,
        )

        # update existing entry
        object.current_quota = this_actual_quota
        object.usage         = this_actual_usage
        object.save if object.changed?
      end
    end

  end
end

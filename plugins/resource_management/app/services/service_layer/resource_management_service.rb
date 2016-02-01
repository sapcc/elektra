module ServiceLayer

  class ResourceManagementService < DomainModelServiceLayer::Service

    def driver
      @driver ||= ResourceManagement::Driver::Fog.new({
        auth_url: self.auth_url,
        region: self.region,
        token: self.token,
        domain_id: self.domain_id,
        project_id: self.project_id,
        service_user_token: Admin::IdentityService.service_user_token  
      })
    end

    def mock!
      @driver = ResourceManagement::Driver::Mock.new()
      return self
    end

    def unmock!
      @driver = nil # will be reinitialized in the next #driver call
      return self
    end

    # Discover existing domains, then:
    # 1. Cleanup Resource objects for deleted domains from local DB.
    # 2. Use sync_domain() to create and/or update Resource objects for all
    #    projects in all known domains.
    def sync_all_domains(options={})
      # check which domains exist in the DB and in Keystone
      all_domain_ids = driver.enumerate_domains.keys
      Rails.logger.info "ResourceManagement > sync_all_domains: domains in Keystone are: #{all_domain_ids.join(' ')}"
      db_domain_ids = ResourceManagement::Resource.pluck('DISTINCT domain_id')

      # drop Resource objects for deleted domains
      old_domain_ids = db_domain_ids - all_domain_ids
      Rails.logger.info "ResourceManagement > sync_all_domains: cleaning up deleted domains: #{old_domain_ids.join(' ')}"
      ResourceManagement::Resource.where(domain_id: old_domain_ids).destroy_all()

      # call sync_domain on all existing domains
      all_domain_ids.each { |domain_id| sync_domain(domain_id, options) }
    end

    # Discover existing projects in a domain, then:
    # 1. Cleanup Resource objects for deleted projects from local DB.
    # 2. Create Resource objects for new projects in local DB.
    def sync_domain(domain_id, options={})
      # foreach resource in an enabled service...
      enabled_services = ResourceManagement::Resource::KNOWN_SERVICES.select { |srv| srv[:enabled] }.map { |srv| srv[:service] }
      enabled_resources = ResourceManagement::Resource::KNOWN_RESOURCES.select { |res| enabled_services.include?(res[:service]) }
      enabled_resources.each do |resource|
        # ...initialize the Resource entry of the domain with approved_quota=0
        # (this is useful if the domain was created outside of the dashboard
        # and no quota has been approved for it yet)
        ResourceManagement::Resource.where(
          cluster_id: nil, # TODO: take cluster assignment into account for brokered services
          domain_id:  domain_id,
          project_id: nil,
          service:    resource[:service],
          name:       resource[:name],
        ).first_or_create(approved_quota: 0)
      end

      # check which projects exist in the DB and in Keystone
      all_project_ids = driver.enumerate_projects(domain_id).keys
      Rails.logger.info "ResourceManagement > sync_domain(#{domain_id}): projects in Keystone are: #{all_project_ids.join(' ')}"
      db_project_ids = ResourceManagement::Resource.where(domain_id: domain_id).pluck('DISTINCT project_id')

      # drop Resource objects for deleted projects (exclude project_id = nil which marks domain-level resource data)
      old_project_ids = db_project_ids - all_project_ids - [nil]
      Rails.logger.info "ResourceManagement > sync_domain(#{domain_id}): cleaning up deleted projects: #{old_project_ids.join(' ')}"
      ResourceManagement::Resource.where(domain_id: domain_id, project_id: old_project_ids).destroy_all()

      # initialize Resource objects for new domains (by recursing into sync_project)
      # or refresh all projects when options[:with_projects] is given
      project_ids_to_update = options[:with_projects] ? all_project_ids : (all_project_ids - db_project_ids)
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
        ) do |obj|
          # special case to set default quotas for newly created projects on swift (mock_service is for test case)
          if this_actual_quota == -1
            if resource[:service] == :object_storage || resource[:service] == :mock_service && resource[:name] == :capacity
              # TODO: put the default quota into the KNOWN_RESOURCES data structure
              obj.current_quota = 1 << 30
              obj.approved_quota = 1 << 30
              apply_current_quota(obj)
            end
          end
        end

        # update existing entry
        object.current_quota = this_actual_quota
        object.usage         = this_actual_usage
        if object.changed?
          object.save
        else
          object.touch # set the updated_at timestamp that's displayed as data age
        end
      end
    end

    # Takes an array of Resource records and applies the current_quota values
    # in them in the backend. This currently only works when all resources are
    # for the same project and service, but a future expansion to support
    # arbitrary sets of resources is possible without changing the interface.
    #
    # The interface is chosen such that quota updates for the same project and
    # service can be grouped in one REST call.
    def apply_current_quota(resources)
      resources = Array.wrap(resources) # convert to array if called with single instance
      return if resources.empty?

      raise ArgumentError, "missing project_id for some resources" if resources.any? { |r| r.project_id.nil? }
      if resources.size > 1
        raise ArgumentError, "resources for multiple domains given"  if resources.map(&:domain_id).uniq.size > 1
        raise ArgumentError, "resources for multiple projects given" if resources.map(&:project_id).uniq.size > 1
        raise ArgumentError, "resources for multiple services given" if resources.map(&:service).uniq.size > 1
      end

      values = {}
      resources.each { |r| values[r.name.to_sym] = r.current_quota }

      res = resources.first
      driver.set_project_quota(res.domain_id, res.project_id, res.service.to_sym, values)
    end

  end
end

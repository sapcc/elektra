module ServiceLayer

  class ResourceManagementService < Core::ServiceLayer::Service

    def driver
      @driver ||= ResourceManagement::Driver::Fog.new({
        auth_url: self.auth_url,
        region: self.region,
        token: self.token,
        domain_id: self.domain_id,
        project_id: self.project_id,
        service_user_token: service_user.token  
      })
    end
    
    def available?(action_name_sym=nil)
      not current_user.service_url('identity',region: region).nil?  
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
      all_domain_ids = enumerate_domains.keys
      Rails.logger.info "ResourceManagement > sync_all_domains: domains in Keystone are: #{all_domain_ids.join(' ')}"
      db_domain_ids = ResourceManagement::Resource.pluck('DISTINCT domain_id')

      # drop Resource objects for deleted domains (unless we are using a
      # Keystone router, in which case enumerate_domains() is not guaranteed to
      # return a full domain list since it only queries one of potentially many
      # backend Keystones)
      if has_keystone_router?
        additional_domain_ids = (all_domain_ids + db_domain_ids).uniq - all_domain_ids
        all_domain_ids = (all_domain_ids + db_domain_ids).uniq
        Rails.logger.warn "ResourceManagement > sync_all_domains: will not trust domain list; also looking at known domains: #{additional_domain_ids.join(' ')}"
      else
        old_domain_ids = db_domain_ids - all_domain_ids
        Rails.logger.info "ResourceManagement > sync_all_domains: cleaning up deleted domains: #{old_domain_ids.join(' ')}"
        ResourceManagement::Resource.where(domain_id: old_domain_ids).destroy_all()
      end

      # call sync_domain on all existing domains
      all_domain_ids.each { |domain_id| sync_domain(domain_id, options) }
    end

    # Discover existing projects in a domain, then:
    # 1. Cleanup Resource objects for deleted projects from local DB.
    # 2. Create Resource objects for new projects in local DB.
    def sync_domain(domain_id, options={})
      # get domain name (this is fast because enumerate_domains() has a cache)
      domain_name = enumerate_domains[domain_id]

      # foreach resource in an enabled service...
      ResourceManagement::ResourceConfig.all.each do |resource|
        # ...initialize the Resource entry of the domain with approved_quota=0
        # (this is useful if the domain was created outside of the dashboard
        # and no quota has been approved for it yet)
        res = ResourceManagement::Resource.where(
          cluster_id: nil, # TODO: take cluster assignment into account for brokered services
          domain_id:  domain_id,
          project_id: nil,
          service:    resource.service_name,
          name:       resource.name,
        ).first_or_create(
          scope_name:     domain_name,
          approved_quota: 0,
        )

        res.scope_name = domain_name
        res.save if res.changed?
      end

      # check which projects exist in the DB and in Keystone
      all_project_ids = driver.enumerate_project_ids(domain_id)
      Rails.logger.info "ResourceManagement > sync_domain(#{domain_id}): projects in Keystone are: #{all_project_ids.join(' ')}"
      db_project_ids = ResourceManagement::Resource.where(domain_id: domain_id).where.not(project_id: nil).pluck('DISTINCT project_id')

      # if using a Keystone router, don't trust an empty project list; it could
      # mean that we're querying the wrong backend and can thus not see the
      # domain (TODO: account for that in the driver by selecting the proper
      # backend)
      if has_keystone_router? and all_project_ids.empty?
        Rails.logger.warn "ResourceManagement > sync_domain(#{domain_id}): will not trust empty project list; also looking at known projects: #{db_project_ids.join(' ')}"
        all_project_ids = db_project_ids
      end

      # drop Resource objects for deleted projects
      old_project_ids = db_project_ids - all_project_ids
      Rails.logger.info "ResourceManagement > sync_domain(#{domain_id}): cleaning up deleted projects: #{old_project_ids.join(' ')}"
      ResourceManagement::Resource.where(domain_id: domain_id, project_id: old_project_ids).destroy_all()
      db_project_ids = db_project_ids - old_project_ids

      # initialize Resource objects for new domains (by recursing into sync_project)
      # or refresh all projects when options[:with_projects] is given
      project_ids_to_update = options[:with_projects] ? all_project_ids : (all_project_ids - db_project_ids)
      project_ids_to_update.each { |project_id| sync_project(domain_id, project_id) }
    end

    # Update Resource entries for the given project with fresh current_quota
    # and usage values (and create missing Resource entries as necessary).
    def sync_project(domain_id, project_id)
      Rails.logger.info "ResourceManagement > sync_project(#{domain_id}, #{project_id})"

      # get the project name
      project_name = driver.get_project_name(domain_id, project_id)

      # fetch current quotas and usage for this project from all services
      actual_quota = {}
      actual_usage = {}
      ResourceManagement::ServiceConfig.all.map(&:name).each do |service|
        actual_quota[service] = driver.query_project_quota(domain_id, project_id, service)
        actual_usage[service] = driver.query_project_usage(domain_id, project_id, service)
      end
      
      # write values into database
      ResourceManagement::ResourceConfig.all.each do |resource|
        # only update if the driver reported any values for this project
        this_actual_quota = actual_quota[resource.service_name][resource.name]
        this_actual_usage = actual_usage[resource.service_name][resource.name]

        # this is the case if account is not accesible or not created 
        next if this_actual_quota.nil? or this_actual_usage.nil?

        domain_resource =  ResourceManagement::Resource.where(domain_id: domain_id, project_id: nil, name:resource.name, service:resource.service_name).first

        # create new Resource entry if necessary
        object = ResourceManagement::Resource.where(
          cluster_id: nil, # TODO: take cluster assignment into account for brokered services
          domain_id:  domain_id,
          project_id: project_id,
          service:    resource.service_name,
          name:       resource.name,
        ).first_or_create(
          scope_name:     project_name,
          usage:          this_actual_usage,
          current_quota:  this_actual_quota,
          approved_quota: 0,
        ) do |obj|
          # enforce default quotas for newly created projects, if not done by the responsible service itself
          # default quota is used only if it was setuped by the domain admin 
          if this_actual_quota == -1 and not domain_resource.try(:default_quota).nil?
            this_actual_quota = domain_resource.default_quota
            obj.current_quota = this_actual_quota
            obj.approved_quota = this_actual_quota
            apply_current_quota(obj)
          end
        end

        # update existing entry
        object.scope_name    = project_name
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

    private

    def enumerate_domains
      # driver.enumerate_domains plus caching
      @enumerate_domains ||= driver.enumerate_domains
    end

    def has_keystone_router?
      value = ENV.fetch('HAS_KEYSTONE_ROUTER', '0')
      Rails.logger.debug "HAS_KEYSTONE_ROUTER = '#{value}'"
      return value == '1'
    end

  end
end

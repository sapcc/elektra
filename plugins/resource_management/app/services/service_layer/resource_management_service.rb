module ServiceLayer

  class ResourceManagementService < Core::ServiceLayer::Service

    def driver
      @driver ||= ResourceManagement::Driver::Fog.new(
        auth_url: self.auth_url,
        region:   self.region,
      )
    end

    def quota_data(options=[])
      result = []

      return result if options.empty?

      domain_id = current_user.domain_id || current_user.project_domain_id
      project_id = current_user.project_id

      options.each do |values|
        resource = ResourceManagement::Resource.where({
          domain_id: domain_id,
          project_id: project_id,
          service: values[:service_name].to_s,
          name: values[:resource_name].to_s
        }).first

        next if resource.nil?

        if values[:usage] and values[:usage].is_a?(Fixnum) and resource.usage != values[:usage]
          resource.usage = values[:usage]
          resource.save
        end

        data_type = ResourceManagement::ServiceConfig.find(values[:service_name]).
          try { |srv| srv.resources.find { |r| r.name == values[:resource_name] } }.
          try { |res| res.data_type }

        unless data_type
          # if this error occurs, add the resource to lib/resource_management/{service,resource}_config.rb
          # and to the driver (please do not try to patch around; this will make a horrible mess)
          raise ArgumentError, "unknown resource '#{values[:service_name]}/#{values[:resource_name]}'"
        end

        result << ResourceManagement::QuotaData.new(
          name: resource.name,
          total: resource.current_quota,
          usage: resource.usage,
          data_type: data_type,
        )
      end
      result
    end


    # This is used in the unit test to replace services.identity by a mock.
    def services_identity
      @services_identity || services.identity
    end

    def available?(action_name_sym=nil)
      services.identity.available?
    end

    def mock!(services_identity)
      @driver            = ResourceManagement::Driver::Mock.new(services_identity.projects)
      @services_identity = services_identity
      return self
    end

    def unmock!
      @driver            = nil # will be reinitialized in the next #driver call
      @services_identity = nil
      return self
    end

    def sync_all_domains
      discover_domains
      ResourceManagement::Resource.
        where(project_id: nil).where.not(scope_name: nil).
        pluck('DISTINCT domain_id').each { |domain_id| sync_domain(domain_id) }
    end

    # Discover existing domains, then:
    # 1. Cleanup Resource objects for deleted domains from local DB.
    # 2. Initialize approved_quota = 0 for new domains.
    def discover_domains
      # list all domains
      domain_name_by_id = {}
      services_identity.domains.each do |domain|
        domain_name_by_id[domain.id] = domain.name
      end

      # check which domains exist in the DB and in Keystone
      all_domain_ids = domain_name_by_id.keys
      db_domain_ids = ResourceManagement::Resource.pluck('DISTINCT domain_id')

      # drop Resource objects for deleted domains (unless we are using a
      # Keystone router, in which case services_identity.domains() is not
      # guaranteed to return a full domain list since it only queries one of
      # potentially many backend Keystones)
      unless has_keystone_router?
        old_domain_ids = db_domain_ids - all_domain_ids
        Rails.logger.info "ResourceManagement > discover_domains: cleaning up deleted domains: #{old_domain_ids.join(' ')}"
        ResourceManagement::Resource.where(domain_id: old_domain_ids).destroy_all()
      end

      # initialize discovered domains, thus enabling listing of domain IDs on local database
      all_domain_ids.each { |domain_id| init_domain(domain_id, domain_name_by_id[domain_id]) }
    end

    def init_domain(domain_id, domain_name)
      # foreach resource in an enabled service...
      ResourceManagement::ResourceConfig.all.each do |resource|
        # ...initialize the Resource entry of the domain with approved_quota=0
        # (when the domain has just been discovered, no one can possibly have
        # approved quota yet)
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
        res.touch # includes res.save if res.changed?
      end
    end

    # Syncs all projects in this domain. If `timeout_secs > 0`, raises
    # `Interrupt` after that many seconds (but only after completing the
    # project sync that's running at that point).
    def sync_domain(domain_id, domain_name=nil, timeout_secs=0)
      start_time = Time.now

      domain_name ||= ResourceManagement::Resource.where(domain_id: domain_id, project_id: nil).pluck('DISTINCT scope_name').first || ''
      init_domain(domain_id, domain_name)
      discover_projects(domain_id)

      while true
        # among the projects that have not been updated since this method was invoked...
        resources = ResourceManagement::Resource.where(domain_id: domain_id).where('project_id IS NOT NULL AND updated_at < ?', start_time)
        # ...find the project that has the most ancient data and update it
        project_id = resources.order(updated_at: :asc).limit(1).pluck(:project_id).first

        if project_id.nil?
          # all projects are in sync
          return
        else
          sync_project(domain_id, project_id)
        end

        # check if we're taking to long
        if timeout_secs > 0
          raise Interrupt, "running time for sync_domain() exceeded" if Time.now.to_f - start_time.to_f > timeout_secs
        end
      end
    end

    # Discover existing projects in a domain, then:
    # 1. Cleanup Resource objects for deleted projects from local DB.
    # 2. Create Resource objects for new projects in local DB.
    def discover_projects(domain_id)
      # check which projects exist in the DB and in Keystone
      project_name_for_id = {}
      begin
        services_identity.projects(domain_id: domain_id).each do |project|
          project_name_for_id[project.id] = project.name
        end
      rescue Excon::Errors::Unauthorized
        project_name_for_id = {}
      end

      all_project_ids = project_name_for_id.keys
      db_project_ids = ResourceManagement::Resource.
        where(domain_id: domain_id).where.not(project_id: nil).
        pluck('DISTINCT project_id')

      # don't trust an empty project list; it could mean that we're lacking
      # permission to query Keystone for the projects in this domain (see
      # above)
      if all_project_ids.empty?
        Rails.logger.warn "ResourceManagement > sync_domain(#{domain_id}): got empty project list from Keystone; could be unauthorized to list projects -> will not attempt to cleanup deleted projects from my local DB"
      else
        # drop Resource objects for deleted projects
        old_project_ids = db_project_ids - all_project_ids
        Rails.logger.info "ResourceManagement > sync_domain(#{domain_id}): cleaning up deleted projects in domain #{domain_id}: #{old_project_ids.join(' ')}"
        ResourceManagement::Resource.where(domain_id: domain_id, project_id: old_project_ids).destroy_all()
      end

      # mark new projects that have not been synced yet (TODO: hack, because DB is not in 2NF)
      (all_project_ids - db_project_ids).each do |project_id|
        ResourceManagement::Resource.where(
          cluster_id: nil,
          domain_id:  domain_id,
          project_id: project_id,
          service:    'resource_management',
          name:       'needs_sync',
        ).first_or_create(
          scope_name:     project_name_for_id[project_id],
          approved_quota: 0,
          current_quota:  0,
          usage:          0,
        )
      end
    end

    # Update Resource entries for the given project with fresh current_quota
    # and usage values (and create missing Resource entries as necessary).
    def sync_project(domain_id, project_id, project_name=nil)
      Rails.logger.info "ResourceManagement > sync_project(#{domain_id}, #{project_id})"

      # get the project name (FIXME: this breaks if the project name is changed
      # in Keystone, but there are entries with the old scope_name in our DB)
      project_name ||= ResourceManagement::Resource.where(project_id: project_id).pluck('DISTINCT scope_name').first \
        || (services_identity.find_project(project_id).name rescue '')

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

      # remove needs_sync dummy resource, if any
      ResourceManagement::Resource.where(project_id: 'project_id', name: 'needs_sync').destroy_all()
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

    def has_keystone_router?
      value = ENV.fetch('HAS_KEYSTONE_ROUTER', '0')
      Rails.logger.debug "HAS_KEYSTONE_ROUTER = '#{value}'"
      return value == '1'
    end

  end
end

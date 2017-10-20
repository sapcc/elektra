module ServiceLayerNg
  class ResourceManagementService < Core::ServiceLayerNg::Service

    def available?(_action_name_sym = nil)
      api.catalog_include_service?('resources', region)
    end

    ############################################################################
    # cloud-admin level

    def find_current_cluster(query={})
      api.resources.get_current_cluster(query).map_to(ResourceManagement::Cluster)
    end

    def list_clusters(query={})
      # Returns a pair of cluster list and ID of current cluster.
      # .map_to() does not work here because the toplevel JSON object contains
      # multiple keys ("clusters" and "current_cluster"), so instantiate the
      # models manually.
      resp = api.resources.get_clusters(query)
      clusters = resp.body['clusters'].map { |data| ResourceManagement::Cluster.new(self, data) }
      return clusters, resp.body['current_cluster']
    end

    def put_cluster_data(services)
      api.resources.set_capacity_for_current_cluster(:cluster => {:services => services})
    end

    ############################################################################
    # domain-admin level

    def find_domain(domain_id, query={})
      api.resources.get_domain(domain_id,query).map_to(ResourceManagement::Domain)
    end

    def list_domains(query={})
      api.resources.get_domains(query).map_to(ResourceManagement::Domain)
    end

    def put_domain_data(domain_id, services)
      api.resources.set_quota_for_domain(domain_id, :domain => {:services => services})
    end

    def discover_projects(domain_id)
      api.resources.discover_projects(domain_id)
    end

    ############################################################################
    # project-admin level

    def find_project(domain_id, project_id, query={})
      # give the domain_id to enrich the Project object with domain_id
      api.resources.get_project(domain_id, project_id, query).map_to(ResourceManagement::Project, domain_id: domain_id)
    end

    def has_project_quotas?(domain_id,project_id,project_domain_id=nil)
      project = find_project(
        domain_id || project_domain_id,
        project_id,
        service:  [ 'compute',                   'network',  'object-store' ],
        resource: [ 'instances', 'ram', 'cores', 'networks', 'capacity'     ],
      )
      # return true if approved_quota of the resource networking:networks is greater than 0
      # OR
      # return true if the sum of approved_quota of the resources compute:instances,
      # compute:ram, compute:cores and object_storage:capacity is greater than 0
      return project.resources.any? { |r| r.quota > 0 }
    end

    def list_projects(domain_id, query={})
      # give the domain_id to enrich the Project object with domain_id
      api.resources.get_projects(domain_id, query).map_to(ResourceManagement::Project, domain_id: domain_id)
    end

    def sync_project_asynchronously(domain_id, project_id)
      api.resources.sync_project(domain_id, project_id)
    end

    def put_project_data(domain_id, project_id, services)
      api.resources.set_quota_for_project(domain_id,project_id, :project => {:services => services})
    end

    def quota_data(domain_id,project_id,options=[])
      return [] if options.empty?

      project = find_project(
        domain_id,
        project_id,
        service: options.collect { |values| values[:service_type] },
        resource: options.collect { |values| values[:resource_name] },
      )
      result = []
      options.each do |values|
        service = project.services.find { |srv| srv.type == values[:service_type].to_sym }
        next if service.nil?
        resource = service.resources.find { |res| res.name == values[:resource_name].to_sym }
        next if resource.nil?

        if values[:usage] and values[:usage].is_a?(Fixnum)
          resource.usage = values[:usage]
        end

        result << resource
      end

      result

    rescue => e
      Rails.logger.error "Error trying to get quota data for project: #{project_id}. Error: #{e}"
      []
    end

  end
end

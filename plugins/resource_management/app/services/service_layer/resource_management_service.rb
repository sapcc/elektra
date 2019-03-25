# frozen_string_literal: true

module ServiceLayer
  class ResourceManagementService < Core::ServiceLayer::Service
    def available?(_action_name_sym = nil)
      elektron.service?('limes')
    end

    def elektron_limes
      @elektron_limes ||= elektron.service(
        'limes', path_prefix: '/v1', interface: 'public'
      )
    end

    def cluster_map
      @cluster_map ||= class_map_proc(ResourceManagement::Cluster)
    end

    def domain_map
      @domain_map ||= class_map_proc(ResourceManagement::Domain)
    end

    ############################################################################
    # cloud-admin level

    def find_cluster(id = 'current', query = {})
      elektron_limes.get("clusters/#{id}", query)
                    .map_to('body.cluster', &cluster_map)
    end

    def list_clusters(query = {})
      # Returns a pair of cluster list and ID of current cluster.
      response = elektron_limes.get('clusters', query)
      [
        response.map_to('body.clusters', &cluster_map),
        response.body['current_cluster']
      ]
    end

    def put_cluster_data(id, services)
      elektron_limes.put("clusters/#{id}") do
        { cluster: { services: services } }
      end
    end

    def get_inconsistencies
      elektron_limes.get("inconsistencies").body['inconsistencies']
    end

    ############################################################################
    # domain-admin level

    def find_domain(id, query = {})
      cluster_id = query[:cluster_id]
      result = elektron_limes.get("domains/#{id}", query, prepare_headers(query))
                             .map_to('body.domain', &domain_map)
      result.cluster_id = cluster_id if cluster_id
      result
    end

    def list_domains(query = {})
      cluster_id = query[:cluster_id]
      result = elektron_limes.get('domains', query, prepare_headers(query))
                    .map_to('body.domains', &domain_map)
      if cluster_id
        result.each { |d| d.cluster_id = cluster_id }
      end
      result
    end

    def put_domain_data(cluster_id, domain_id, services)
      options = {}
      options[:headers] = { "X-Limes-Cluster-ID" => cluster_id } if cluster_id
      elektron_limes.put("domains/#{domain_id}", options) do
        { domain: { services: services } }
      end
    end

    def discover_projects(domain_id)
      elektron_limes.post("domains/#{domain_id}/projects/discover")
    end

    ############################################################################
    # project-admin level

    def find_project(domain_id, project_id, query = {})
      # give the domain_id to enrich the Project object with domain_id
      elektron_limes.get("domains/#{domain_id}/projects/#{project_id}", query)
                    .map_to('body.project') do |data|
        ResourceManagement::Project.new(self, data.merge(domain_id: domain_id))
      end
    end

    def has_project_quotas?(domain_id, project_id, project_domain_id = nil)
      project = find_project(
        domain_id || project_domain_id,
        project_id,
        service:  %w[compute network object-store],
        resource: %w[instances ram cores networks capacity]
      )
      # return true if approved_quota of the resource networking:networks
      # is greater than 0 OR
      # return true if the sum of approved_quota of the resources
      # compute:instances, compute:ram, compute:cores and
      # object_storage:capacity is greater than 0
      project.resources.any? { |r| r.quota.positive? }
    end

    def list_projects(domain_id, query = {})
      # give the domain_id to enrich the Project object with domain_id
      elektron_limes.get("domains/#{domain_id}/projects", query).map_to(
        'body.projects'
      ) do |data|
        ResourceManagement::Project.new(self, data.merge(domain_id: domain_id))
      end
    end

    def sync_project_asynchronously(domain_id, project_id)
      elektron_limes.post("domains/#{domain_id}/projects/#{project_id}/sync")
    end

    def put_project_data(domain_id, project_id, services, bursting = nil)
      unless bursting
        elektron_limes.put("domains/#{domain_id}/projects/#{project_id}") do
          { project: { services: services } }
        end
      else
        # currently not allowed to set quotas and bursting in the same request
        elektron_limes.put("domains/#{domain_id}/projects/#{project_id}") do
          { project: { bursting: bursting } }
        end
      end
    end

    ############################################################################

    def quota_data(domain_id,project_id,options=[])
      # TODO: When moving this into plugins/resources/, refactor as follows.
      #
      # 1. Use the Elektra service user to make the request.
      # 2. Remove the policy check for "access_to_project" from all callsites.
      return [] if options.empty?

      project = find_project(
        domain_id,
        project_id,
        service: options.collect { |values| values[:service_type] },
        resource: options.collect { |values| values[:resource_name] }
      )

      options.each_with_object([]) do |values, result|
        service = project.services.find do |srv|
          srv.type == values[:service_type].to_sym
        end
        next if service.nil?
        resource = service.resources.find do |res|
          res.name == values[:resource_name].to_sym
        end
        next if resource.nil?

        if values[:usage] && values[:usage].is_a?(Integer)
          resource.usage = values[:usage]
        end

        result << resource
      end
    rescue => e
      Rails.logger.error "Error trying to get quota data for project: #{project_id}. Error: #{e}"
      []
    end

    private

    def prepare_headers(query)
      if cluster_id = query.delete(:cluster_id)
        { headers: { "X-Limes-Cluster-ID" => cluster_id } }
      else
        {}
      end
    end

  end
end

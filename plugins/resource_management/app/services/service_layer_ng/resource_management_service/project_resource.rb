module ServiceLayerNg
  # This module implements Openstack Group API
  module ResourceManagementService::ProjectResource
    
    def find_project(domain_id, project_id, query={})
      debug "[resource management-service][ProjectResource] -> find_project -> GET /v1/domains/#{domain_id}/projects/#{project_id}"
      debug "[resource management-service][ProjectResource] -> find_project -> Query: #{query}"
      # give the domain_id to enrich the Project object with domain_id
      api.resources.get_project(domain_id, project_id, query).map_to(ResourceManagement::Project,domain_id: domain_id)
    end

    def has_project_quotas?(domain_id,project_id,project_domain_id)
      debug "[resource management-service][ProjectResource] -> has_project_quotas?"
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
      debug "[resource management-service][ProjectResource] -> list_projects -> GET /v1/domains/#{domain_id}"
      debug "[resource management-service][ProjectResource] -> list_projects -> Query: #{query}"
      # give the domain_id to enrich the Project object with domain_id
      api.resources.get_projects(domain_id, query).map_to(ResourceManagement::Project,domain_id: domain_id)
    end

    def sync_project_asynchronously(domain_id, project_id)
      debug "[resource management-service][ProjectResource] -> sync_project_asynchronously -> POST /v1/domains/#{domain_id}/projects/#{project_id}/sync"
      api_client.resources.sync_project(domain_id, project_id)
    end

    def put_project_data(domain_id, project_id, services)
      debug "[resource management-service][ProjectResource] -> put_project_data -> PUT /v1/domains/#{domain_id}/projects/#{project_id}"
      api.resources.set_quota_for_project(domain_id,project_id, :project => {:services => services})
    end
    
  end
end
module ServiceLayer

  class ResourceManagementService < DomainModelServiceLayer::Service

    KNOWN_RESOURCES = {
      # service name => names of resources
      object_storage: [ :capacity ]
    }

    def driver
      @driver ||= ResourceManagement::Driver::Fog.new({
        auth_url: self.auth_url,
        region: self.region,
        token: self.token,
        domain_id: self.domain_id,
        project_id: self.project_id,
      })
    end

    # Discover existing domains and projects, then:
    # 1. Cleanup Resource objects from local DB for projects that have been deleted.
    # 2. Create Resource objects in local DB for projects that have been created.
    def sync_projects
      known_projects = driver.enumerate_projects
      is_known_project = {}
      known_projects.each { |proj| is_known_project[ proj[:id] ] = true }

      # drop Resource objects for projects that have been deleted
      ResourceManagement::Resource.select(:project_id).uniq.pluck(:project_id).each do |project_id|
        next if is_known_project[project_id]
        # TODO: this loop might run very long, so new projects might be created during its
        # run; recheck that the project is gone before actually deleting its resource entries
        ResourceManagement::Resource.where(project_id: project_id).each(&:destroy)
      end

      # create missing Resource entries
      known_projects.each do |proj|
        KNOWN_RESOURCES.each do |service_name, resource_names|
          resource_names.each do |resource_name|
            puts ">>>", proj.inspect
            ResourceManagement::Resource.where(
              cluster_id: nil,
              domain_id:  proj[:domain_id],
              project_id: proj[:id],
              service:    service_name,
              name:       resource_name,
            ).first_or_create(
              current_quota:  0,
              approved_quota: 0,
              usage:          0,
            )
          end
        end
      end
    end

    # Refresh all existing Resource entries for the given service (e.g. :object_storage) by
    # querying current quota and usage from the backend.
    def sync_service(service)
      # TODO: implementation is too specific (e.g. it relies on the fact that service
      # :object_storage has only one resource)
      ResourceManagement::Resource.where(service: service).where.not(project_id: nil).each do |resource|
        if service == :object_storage
          data = driver.get_project_usage_swift(resource.domain_id, resource.project_id)
          resource.current_quota = data[:quota]
          resource.usage         = data[:capacity]
          resource.save
        end
      end
    end

  end
end

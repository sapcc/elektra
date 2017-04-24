module ServiceLayer

  class ResourceManagementService < Core::ServiceLayer::Service

    def driver
      @driver ||= ResourceManagement::Driver::Misty.new(
        auth_url:   self.auth_url,
        region:     self.region,
        token:      self.token,
        domain_id:  self.domain_id,
        project_id: self.project_id,
      )
    end

    def available?(action_name_sym=nil)
      not current_user.service_url('resources', region: region).nil?
    end

    def find_project(domain_id, project_id, options={})
      driver.map_to(ResourceManagement::Project, domain_id: domain_id).get_project_data(domain_id, project_id, options)
    end

    def list_projects(domain_id, options={})
      driver.map_to(ResourceManagement::Project, domain_id: domain_id).get_project_data(domain_id, nil, options)
    end

    def find_domain(domain_id, options={})
      driver.map_to(ResourceManagement::Domain).get_domain_data(domain_id, options)
    end

    def list_domains(options={})
      driver.map_to(ResourceManagement::Domain).get_domain_data(nil, options)
    end

    def find_current_cluster(options={})
      driver.map_to(ResourceManagement::Cluster).get_cluster_data(options)
    end

    def sync_project_asynchronously(domain_id, project_id)
      driver.sync_project_asynchronously(domain_id, project_id)
    end

    def has_project_quotas?
      resources = ResourceManagement::Resource.where({
        domain_id: (current_user.domain_id || current_user.project_domain_id),
        project_id: current_user.project_id
      })

      # return true if approved_quota of the resource networking:networks is greater than 0
      return true if resources.where({
        service: 'networking',
        name: 'networks'
      }).collect{|r| (r.approved_quota || 0)}.min.try(:>,0)

      # OR
      # return true if the sum of approved_quota of the resources compute:instances,
      # compute:ram, compute:cores and object_storage:capacity is greater than 0
      return true if resources.where({
        service: ['compute','object_storage'],
        name: ['instances','ram','cores','capacity']
      }).collect{|r| (r.approved_quota || 0)}.min.try(:>,0)

      return false
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

  end
end

module ResourceManagement
  class NewStyleResource < Core::ServiceLayer::Model
    include ManualValidation

    validates_presence_of :quota, unless: :cluster_id
    validate :validate_quota
    validates_presence_of :comment, if: Proc.new { |res| res.capacity.try(:>=, 0) }

    def name
      read(:name).to_sym
    end
    def category
      (read(:category) || :"").to_sym
    end

    def service_type
      read(:service_type)
    end
    def service_area
      read(:service_area)
    end
    def shared_service?
      read(:service_shared)
    end

    def data_type
      Core::DataType.from_unit_name(read(:unit) || '')
    end

    def externally_managed?
      read(:externally_managed) || false
    end

    def project_id
      read(:project_id)
    end
    def project_name
      read(:project_name)
    end
    def project_domain_id
      read(:project_domain_id)
    end
    def domain_id
      read(:domain_id)
    end
    def domain_name
      read(:domain_name)
    end
    def cluster_id
      read(:cluster_id)
    end
    def sortable_name
      (project_name or domain_name or cluster_id).downcase
    end

    def usage
      read(:usage) || 0
    end

    # domain and project only
    def quota
      read(:quota) || 0
    end
    def backend_quota
      read(:backend_quota) || nil
    end

    # project only
    def current_quota
      read(:backend_quota) || quota
    end

    # domain only
    def projects_quota
      read(:projects_quota) || 0
    end
    def infinite_backend_quota?
      read(:infinite_backend_quota) || false
    end

    # cluster only
    def capacity
      c = read(:capacity)
      return (c && c >= 0) ? c : nil
    end
    def comment
      return nil if capacity.nil?
      read(:comment) || nil
    end
    def domains_quota
      read(:domains_quota) || 0
    end

    def save
      return self.valid? && perform_update
    end

    def perform_update
      services = [{
        type: service_type,
        resources: [{
          name:     name,
          quota:    read(:quota),
          capacity: read(:capacity),
          comment:  read(:comment),
        }.reject { |_,v| v.nil? }],
      }]

      if project_id and project_domain_id
        rescue_api_errors { @service.put_project_data(project_domain_id, project_id, services) }
      elsif domain_id
        rescue_api_errors { @service.put_domain_data(cluster_id, domain_id, services) }
      elsif cluster_id
        rescue_api_errors { @service.put_cluster_data(services) }
      else
        raise ArgumentError, "found nowhere to put quota: #{attributes.inspect}"
      end
    end

    def clone
      return self.class.new(@service, attributes.clone)
    end

    # for quota display in other services
    def available
      return quota < 0 ? -1 : quota - usage
    end
    def available_as_display_string
      return "#{data_type.format(available)} #{I18n.t("resource_management.#{name}")}"
    end

    # project level: if burst_usage > 0
    # usage = burst_usage inclusive
    #|---------------------------------|----|---|
    #|                                 |    |  -|-> maximum = quota + (quota*multiplier)
    #|---------------------------------|----|---|
    #                                  |     fill = usage
    #                                  | threshold = quota
    #

    def burst_usage
     read(:burst_usage) || 0
    end

    private

    def validate_quota
      if project_id
        errors.add(:quota, 'is below usage') if usage > quota
      elsif domain_id
        errors.add(:quota, 'is less than sum of project quotas') if projects_quota > quota
      end
    end

  end
end

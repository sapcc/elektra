module ResourceManagement

  # This class describes a type of resource that this plugin can query.
  # The set of known ResourceConfigs is created in the all() class method.
  # Attributes include:
  #
  # - name          (Symbol):        the name of this resource (unique per service)
  # - service_name  (Symbol):        the name of the service that manages this resource
  # - service       (ServiceConfig): configuration for this service
  # - data_type     (DataType):      used for parsing and formatting quota/usage values for this resource
  #
  # - significant   (Boolean):       whether this resource is shown on the package comparison table

  class ResourceConfig
    attr_reader :name, :service_name, :data_type, :auto_approved_quota, :package_config

    def initialize(service_name, name, package_config, options={})
      @name           = name.to_sym
      @service_name   = service_name.to_sym
      @data_type      = Core::DataType.new(options.fetch(:data_type, :number), options[:data_sub_type])
      @package_config = package_config
      @auto_approved_quota = options.fetch(:auto_approved_quota, 0)
    end

    def service
      ResourceManagement::ServiceConfig.find(@service_name)
    end

    def significant?
      @package_config.significant?
    end

    def value_for_package(package)
      @package_config.value_for_package(package)
    end

    def self.all
      # NOTE: pkg() is a shorthand for ResourceManagement::PackageConfig.new()
      @all ||= [
        new(:compute,                   :cores,                       pkg(true, 10)),
        new(:compute,                   :instances,                   pkg(false, 5)),
        new(:compute,                   :ram,                         pkg(true, 8 << 10), data_type: :bytes, data_sub_type: :mega),
        # new(:compute,                   :key_pairs,                   pkg(false, 0)),
        # new(:compute,                   :metadata_items,              pkg(false, 0)),
        # new(:compute,                   :server_groups,               pkg(false, 0)),
        # new(:compute,                   :server_group_members,        pkg(false, 0)),
        # new(:compute,                   :injected_files,              pkg(false, 0)),
        # new(:compute,                   :injected_file_content_bytes, pkg(false, 0), data_type: :bytes),
        # new(:compute,                   :injected_file_path_bytes,    pkg(false, 0), data_type: :bytes),
        # new(:compute,                   :fixed_ips,                   pkg(false, 0)),
        new(:networking,                :floating_ips,                pkg(true, 2)),
        new(:networking,                :networks,                    pkg(true, 1)),
        new(:networking,                :subnets,                     pkg(false, 1)),
        new(:networking,                :subnet_pools,                pkg(false, 0)),
        new(:networking,                :ports,                       pkg(false, 500)),
        new(:networking,                :routers,                     pkg(false, 1)),
        new(:networking,                :security_groups,             pkg(false, 2),  auto_approved_quota: 1), # auto-approve initial "default" security group
        new(:networking,                :security_group_rules,        pkg(false, 16), auto_approved_quota: 4), # auto-approve initial "default" security group
        new(:networking,                :rbac_policies,               pkg(false, 5)),
        new(:dns,                       :zones,                       pkg(false, 0)),
        new(:dns,                       :recordsets,                  pkg(false, 5)),
        new(:block_storage,             :capacity,                    pkg(true, 16), data_type: :bytes, data_sub_type: :giga),
        new(:block_storage,             :snapshots,                   pkg(false, 2)),
        new(:block_storage,             :volumes,                     pkg(false, 2)),
        new(:object_storage,            :capacity,                    pkg(true, 1 << 30), data_type: :bytes),
        new(:shared_filesystem_storage, :share_networks,              pkg(false, 0)),
        new(:shared_filesystem_storage, :shares,                      pkg(false, 0)),
        new(:shared_filesystem_storage, :share_snapshots,             pkg(false, 0)),
        new(:shared_filesystem_storage, :share_capacity,              pkg(false, 0), data_type: :bytes, data_sub_type: :giga),
        new(:shared_filesystem_storage, :snapshot_capacity,           pkg(false, 0), data_type: :bytes, data_sub_type: :giga),
        new(:loadbalancing,             :loadbalancers,               pkg(false, 0)),
        new(:loadbalancing,             :listeners,                   pkg(false, 0)),
        new(:loadbalancing,             :pools,                       pkg(false, 0)),
        new(:loadbalancing,             :healthmonitors,              pkg(false, 0)),
        new(:loadbalancing,             :l7policies,                  pkg(false, 0)),
        # :mock_service can be enabled with ResourceManagement::ServiceConfig.mock!
        new(:mock_service,              :things,                      pkg(false, 0)),
        new(:mock_service,              :capacity,                    pkg(false, 0), data_type: :bytes),
      ]

      # only show resources for enabled services
      enabled_services = ServiceConfig.all.map(&:name)
      return @all.select { |res| enabled_services.include?(res.service_name) }
    end

    private

    # shortcut for the list in all()
    def self.pkg(*args)
      return ::ResourceManagement::PackageConfig.new(*args)
    end

  end

end

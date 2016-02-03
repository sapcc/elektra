module ResourceManagement

  # This class describes a type of resource that this plugin can query.
  # The set of known ResourceConfigs is created in the all() class method.
  # Attributes include:
  #
  # - name          (Symbol):        the name of this resource (unique per service)
  # - service_name  (Symbol):        the name of the service that manages this resource
  # - service       (ServiceConfig): configuration for this service
  # - data_type     (DataType):      used for parsing and formatting quota/usage values for this resource
  # - default_quota (Fixnum or nil): default quota for new projects that don't have one set
  #
  # The default_quota is only needed if the service does not configure a
  # default quota for new projects by itself.
  class ResourceConfig
    attr_reader :name, :service_name, :data_type, :default_quota

    def initialize(service_name, name, options={})
      @name          = name.to_sym
      @service_name  = service_name.to_sym
      @data_type     = ResourceManagement::DataType.new(options.fetch(:data_type, :number))
      @default_quota = options.fetch(:default_quota, nil)
    end

    def service
      ResourceManagement::ServiceConfig.find(@service_name)
    end

    def self.all
      @all ||= [
        new(:compute,        :cores          ),
        new(:compute,        :instances      ),
        new(:compute,        :ram,            data_type: :bytes),
        new(:network,        :floating_ips   ),
        new(:network,        :networks       ),
        new(:network,        :ports          ),
        new(:network,        :routers        ),
        new(:network,        :security_groups),
        new(:network,        :subnets        ),
        new(:block_storage,  :capacity,       data_type: :bytes),
        new(:block_storage,  :snapshots      ),
        new(:block_storage,  :volumes        ),
        new(:object_storage, :capacity,       data_type: :bytes, default_quota: 1 << 30),
        # :mock_service can be enabled with ResourceManagement::ServiceConfig.mock!
        new(:mock_service,   :things         ),
        new(:mock_service,   :capacity,       data_type: :bytes, default_quota: 1 << 30),
      ]

      # only show resources for enabled services
      enabled_services = ServiceConfig.all.map(&:name)
      return @all.select { |res| enabled_services.include?(res.service_name) }
    end

  end

end

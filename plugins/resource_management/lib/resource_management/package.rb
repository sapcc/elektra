module ResourceManagement
  # This class describes a pre-defined package containing quotas for multiple resources.
  class Package
    attr_reader :key

    def initialize(key, quotas_by_service)
      @key = key
      @quotas = quotas_by_service
    end

    def self.all
      PACKAGES
    end

    def self.find(key)
      PACKAGES.find { |pkg| pkg.key == key }
    end

    def quota(service_type, resource_name)
      @quotas[service_type.to_sym].try { |q| q[resource_name.to_sym] } || 0
    end

    # Returns whether this resource should be shown by default on the package comparison table.
    def self.significant?(service_type, resource_name)
      SIGNIFICANT_RESOURCES.include?(
        "#{service_type.to_s}/#{resource_name.to_s}",
      )
    end

    PACKAGES = [
      # NOTE: when adding new packages, please also add the human-readable name to plugins/resource_management/config/locales/en.yml
      new(
        "P",
        {
          compute: {
            cores: 10,
            instances: 5,
            ram: 8 << 10, # 8 * 2^10 MiB = 8 GiB
          },
          network: {
            floating_ips: 2,
            networks: 1,
            subnets: 1,
            ports: 500,
            rbac_policies: 5,
            routers: 1,
            security_group_rules: 100,
            security_groups: 20,
          },
          dns: {
            recordsets: 5,
          },
          "object-store": {
            capacity: 1 << 30, # 2^30 bytes = 1 GiB
          },
          volumev2: {
            capacity: 16, # GiB
            snapshots: 2,
            volumes: 2,
          },
        },
      ),
    ]

    SIGNIFICANT_RESOURCES = %w[
      compute/cores
      compute/ram
      network/floating_ips
      network/networks
      object-store/capacity
      volumev2/capacity
    ]
  end
end

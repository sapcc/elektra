# frozen_string_literal: true

module Compute
  # Represents the Openstack Hypervisor
  class Hypervisor < Core::ServiceLayer::Model
    def name
      read("hypervisor_hostname")
    end

    def type
      read("hypervisor_type")
    end

    def version
      read("hypervisor_version")
    end

    def host
      read("service")["host"]
    end

    def vcpus_used
      Core::DataType.new(:number).format(read("vcpus_used"))
    end

    def vcpus_total
      vcpus = CPU_OVERCOMMIT * read("vcpus").to_i
      Core::DataType.new(:number).format(vcpus)
    end

    def memory_used
      Core::DataType.new(:bytes, :mega).format(read("memory_mb_used"))
    end

    def memory_total
      Core::DataType.new(:bytes, :mega).format(read("memory_mb"))
    end

    def local_storage_used
      Core::DataType.new(:bytes, :giga).format(read("local_gb_used"))
    end

    def local_storage_total
      Core::DataType.new(:bytes, :giga).format(read("local_gb"))
    end

    def disabled_reason
      read("service")["disabled_reason"]
    end
  end
end

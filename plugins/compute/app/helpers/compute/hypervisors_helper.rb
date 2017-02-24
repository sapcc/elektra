module Compute
  module HypervisorsHelper
    def vcpus_of(hypervisor)
      "#{hypervisor.vcpus_used} of #{hypervisor.vcpus_total}"
    end

    def memory_of(hypervisor)
      "#{hypervisor.memory_used} of #{hypervisor.memory_total}"
    end

    def local_storage_of(hypervisor)
      "#{hypervisor.local_storage_used} of #{hypervisor.local_storage_total}"
    end
  end
end

module Compute
  module HypervisorsHelper
    def accumulated_hypervisors(hypervisors)
      hypervisors
        .each_with_object({}) do |hv, map|
          map[hv.availability_zone] ||= {
            availability_zone: hv.availability_zone,
            vcpus_used: 0,
            vcpus_total: 0,
            memory_used: 0,
            memory_total: 0,
            local_storage_used: 0,
            local_storage_total: 0,
            running_vms: 0,
            items: [],
          }

          map[hv.availability_zone][:vcpus_used] += hv.attributes[
            "vcpus_used"
          ].to_i
          map[hv.availability_zone][:vcpus_total] += hv.attributes["vcpus"].to_i
          map[hv.availability_zone][:memory_used] += hv.attributes[
            "memory_mb_used"
          ].to_f
          map[hv.availability_zone][:memory_total] += hv.attributes[
            "memory_mb"
          ].to_f
          map[hv.availability_zone][:local_storage_used] += hv.attributes[
            "local_gb_used"
          ].to_f
          map[hv.availability_zone][:local_storage_total] += hv.attributes[
            "local_gb"
          ].to_f
          map[hv.availability_zone][:running_vms] += hv.attributes[
            "running_vms"
          ].to_i
          map[hv.availability_zone][:items] << hv
        end
        .values
        .sort_by! { |data| data[:availability_zone] }
        .each do |data|
          data[:vcpus_used] = Core::DataType.new(:number).format(
            data[:vcpus_used],
          )
          data[:vcpus_total] = Core::DataType.new(:number).format(
            CPU_OVERCOMMIT * data[:vcpus_total],
          )
          data[:memory_used] = Core::DataType.new(:bytes, :mega).format(
            data[:memory_used],
          )
          data[:memory_total] = Core::DataType.new(:bytes, :mega).format(
            data[:memory_total],
          )
          data[:local_storage_used] = Core::DataType.new(:bytes, :giga).format(
            data[:local_storage_used],
          )
          data[:local_storage_total] = Core::DataType.new(:bytes, :giga).format(
            data[:local_storage_total],
          )
        end
    end

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

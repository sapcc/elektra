module Compute
  class Hypervisor < Core::ServiceLayer::Model
    def name
      read('hypervisor_hostname')
    end

    def type
      read('hypervisor_type')
    end

    def version
      read('hypervisor_version')
    end

    def host
      read('service')['host']
    end

    def disabled_reason
      read('service')['disabled_reason']
    end
  end
end

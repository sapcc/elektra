module Compute
  class Hypervisor < Core::ServiceLayer::Model
    def name
      read('hypervisor_hostname')
    end

    def type
      read('hypervisor_type')
    end
  end
end

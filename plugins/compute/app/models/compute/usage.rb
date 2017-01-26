module Compute
  class Usage < Core::ServiceLayer::Model
    def cores
      read('totalCoresUsed')
    end

    def instances
      read('totalInstancesUsed')
    end

    def ram
      read('totalRAMUsed')
    end
  end
end

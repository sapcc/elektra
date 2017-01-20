module Compute
  class HypervisorServer < Core::ServiceLayer::Model
    def id
      read('uuid')
    end
  end
end

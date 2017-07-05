module Compute
  class HypervisorServer < Core::ServiceLayerNg::Model
    def id
      read('uuid')
    end
  end
end

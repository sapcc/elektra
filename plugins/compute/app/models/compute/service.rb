module Compute
  class Service < Core::ServiceLayerNg::Model
    def name
      read('binary')
    end

    def enabled?
      status == 'enabled'
    end
  end
end

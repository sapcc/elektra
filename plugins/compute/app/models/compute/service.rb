module Compute
  class Service < Core::ServiceLayer::Model
    def name
      read('binary')
    end

    def enabled?
      status == 'enabled'
    end
  end
end

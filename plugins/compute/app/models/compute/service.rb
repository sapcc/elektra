# frozen_string_literal: true

module Compute
  # Represents the Service 
  class Service < Core::ServiceLayer::Model
    def name
      read('binary')
    end

    def enabled?
      status == 'enabled'
    end
  end
end

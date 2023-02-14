# frozen_string_literal: true

module Compute
  # Represents the Compute Usage
  class Usage < Core::ServiceLayer::Model
    def cores
      read("totalCoresUsed")
    end

    def instances
      read("totalInstancesUsed")
    end

    def ram
      read("totalRAMUsed")
    end
  end
end

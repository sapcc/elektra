# frozen_string_literal: true

module Compute
  # Openstack Hypervisor Server
  class HypervisorServer < Core::ServiceLayer::Model
    def id
      read("uuid")
    end
  end
end

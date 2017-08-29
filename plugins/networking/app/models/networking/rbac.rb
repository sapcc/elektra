# frozen_string_literal: true

module Networking
  # represents the Openstack RBAC
  class Rbac < Core::ServiceLayerNg::Model
    validates :target_tenant, presence: true
  end
end

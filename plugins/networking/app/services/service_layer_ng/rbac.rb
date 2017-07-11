# frozen_string_literal: true

module ServiceLayerNg
  # Implements Openstack RBAC
  module Rbac
    def rbacs(filter = {})
      api.networking.list_rbac_policies(filter).map_to(Networking::Rbac)
    end

    def find_rbac!(id)
      return nil unless id
      api.networking.show_rbac_policy_details(id).map_to(Networking::Rbac)
    end

    def find_rbac(id)
      find_rbac!(id)
    rescue
      nil
    end

    def new_rbac(attributes = {})
      map_to(Networking::Rbac, attributes)
    end
  end
end

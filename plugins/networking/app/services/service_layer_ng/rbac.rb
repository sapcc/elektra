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

    # Model Interface
    def create_rbac(attributes)
      api.networking.create_rbac_policy(rbac_policy: attributes).data
    end

    def delete_rbac(id)
      api.networking.delete_rbac_policy(id)
    end

    def update_rbac(id, attributes)
      api.networking.update_rbac_policy(id, rbac_policy: attributes).data
    end
  end
end

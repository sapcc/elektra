# frozen_string_literal: true

module Compute
  # Represents the Openstack Flavor
  class FlavorAccess < Core::ServiceLayer::Model
    def save
      # execute before callback
      before_save
      return false unless valid?
      rescue_api_errors do
        @service.add_flavor_access_to_tenant(flavor_id, tenant_id)
        after_save
      end
    end

    def destroy
      before_destroy
      rescue_api_errors do
        @service.remove_flavor_access_from_tenant(flavor_id, tenant_id)
      end
    end
  end
end

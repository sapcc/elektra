# frozen_string_literal: true

module ServiceLayerNg
  module ComputeServices
    # This module implements Openstack Domain API
    module Flavor
      def new_flavor(params = {})
        # this is used for inital create flavor dialog
        map_to(Compute::Flavor, params)
      end

      def flavors(filter = {})
        api.compute.list_flavors_with_details(filter).map_to(Compute::Flavor)
      end

      def find_flavor!(flavor_id, use_cache = false)
        cache_key = "server_flavor_#{flavor_id}"

        flavor_data = if use_cache
                        Rails.cache.fetch(cache_key, expires_in: 24.hours) do
                          api.compute.show_flavor_details(flavor_id).data
                        end
                      else
                        data = api.compute.show_flavor_details(flavor_id).data
                        Rails.cache.write(cache_key, data,
                                          expires_in: 24.hours)
                        data
                      end

        return nil if flavor_data.nil?
        map_to(Compute::Flavor, flavor_data)
      end

      def find_flavor(flavor_id, use_cache = false)
        find_flavor!(flavor_id, use_cache)
      rescue
        nil
      end

      def add_flavor_access_to_tenant(flavor_id, tenant_id)
        api.compute.add_flavor_access_to_tenant_addtenantaccess_action(
          flavor_id, 'addTenantAccess' => { 'tenant' => tenant_id }
        )
      end

      def remove_flavor_access_from_tenant(flavor_id, tenant_id)
        api.compute.remove_flavor_access_from_tenant_removetenantaccess_action(
          flavor_id, 'removeTenantAccess' => { 'tenant' => tenant_id.to_s }
        )
      end


      def flavor_members(flavor_id)
        api.compute.list_flavor_access_information_for_given_flavor(flavor_id)
           .map_to(Compute::FlavorAccess)
      end

      def find_flavor_metadata!(flavor_id)
        api.compute.list_extra_specs_for_a_flavor(flavor_id)
           .map_to(Compute::FlavorMetadata)
      end

      def find_flavor_metadata(flavor_id)
        find_flavor_metadata!(flavor_id)
      rescue
        nil
      end

      def new_flavor_metadata(flavor_id)
        Compute::FlavorMetadata.new(self, flavor_id: flavor_id)
      end

      def new_flavor_access(params = {})
        Compute::FlavorAccess.new(self, params)
      end

      ###################### MODEL INTERFACE ####################
      def create_flavor(attributes)
        api.compute.create_flavor('flavor' => attributes).data
      end

      def delete_flavor(id)
        api.compute.delete_flavor(id)
      end

      def create_flavor_metadata(flavor_id, flavor_extras)
        api.compute.create_extra_specs_for_a_flavor(
          flavor_id, 'extra_specs' => flavor_extras
        ).data
      end

      def delete_flavor_metadata(flavor_id, key)
        api.compute.delete_an_extra_spec_for_a_flavor(flavor_id, key)
      end
    end
  end
end

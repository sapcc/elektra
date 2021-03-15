# frozen_string_literal: true

module ServiceLayer
  module ComputeServices
    # This module implements Openstack Domain API
    module Flavor
      OBSOLETE_FLAVORS_PREFIX = "x_deprecated"
      def flavor_map
        @flavor_map ||= class_map_proc(Compute::Flavor)
      end

      def flavor_access_map
        @flavor_access_map ||= class_map_proc(Compute::FlavorAccess)
      end

      def flavor_metadata_map
        @flavor_metadata_map ||= class_map_proc(Compute::FlavorMetadata)
      end

      def new_flavor(params = {})
        # this is used for inital create flavor dialog
        flavor_map.call(params)
      end

      def flavors(filter = {})
        elektron_compute.get('flavors/detail', filter).map_to(
          'body.flavors', &flavor_map
        ).select{|f| !f.id.starts_with? OBSOLETE_FLAVORS_PREFIX }
      end

      def find_flavor!(flavor_id, use_cache = false)
        cache_key = "server_flavor_#{flavor_id}"

        flavor_data = if use_cache
                        Rails.cache.fetch(cache_key, expires_in: 24.hours) do
                          elektron_compute.get("flavors/#{flavor_id}")
                                          .body['flavor']
                        end
                      else
                        data = elektron_compute.get("flavors/#{flavor_id}")
                                               .body['flavor']
                        Rails.cache.write(cache_key, data,
                                          expires_in: 24.hours)
                        data
                      end

        return nil if flavor_data.nil?
        flavor_map.call(flavor_data)
      end

      def find_flavor(flavor_id, use_cache = false)
        find_flavor!(flavor_id, use_cache)
      rescue Elektron::Errors::ApiResponse
        nil
      end

      def add_flavor_access_to_tenant(flavor_id, tenant_id)
        elektron_compute.post("flavors/#{flavor_id}/action") do
          { 'addTenantAccess' => { 'tenant' => tenant_id.to_s } }
        end
      end

      def remove_flavor_access_from_tenant(flavor_id, tenant_id)
        elektron_compute.post("flavors/#{flavor_id}/action") do
          { 'removeTenantAccess' => { 'tenant' => tenant_id.to_s } }
        end
      end

      def flavor_members(flavor_id)
        elektron_compute.get("/flavors/#{flavor_id}/os-flavor-access").map_to(
          'body.flavor_access', &flavor_access_map
        )
      end

      def find_flavor_metadata!(flavor_id)
        elektron_compute.get("flavors/#{flavor_id}/os-extra_specs").map_to(
          'body.extra_specs', &flavor_metadata_map
        )
      end

      def find_flavor_metadata(flavor_id)
        find_flavor_metadata!(flavor_id)
      rescue Elektron::Errors::ApiResponse
        nil
      end

      def new_flavor_metadata(flavor_id)
        flavor_metadata_map.call(flavor_id: flavor_id)
      end

      def new_flavor_access(params = {})
        flavor_access_map.call(params)
      end

      ###################### MODEL INTERFACE ####################
      def create_flavor(attributes)
        elektron_compute.post('flavors') do
          { 'flavor' => attributes }
        end.body['flavor']
      end

      def delete_flavor(id)
        elektron_compute.delete("flavors/#{id}")
      end

      def create_flavor_metadata(flavor_id, flavor_extras)
        elektron_compute.post("flavors/#{flavor_id}/os-extra_specs") do
          { 'extra_specs' => flavor_extras }
        end.body['extra_specs']
      end

      def delete_flavor_metadata(flavor_id, key)
        elektron_compute.delete(
          "flavors/#{flavor_id}/os-extra_specs/#{key}"
        )
      end
    end
  end
end

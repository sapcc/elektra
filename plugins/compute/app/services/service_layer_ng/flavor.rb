module ServiceLayerNg
  # This module implements Openstack Domain API
  module Flavor

    def new_flavor(params = {})
      # this is used for inital create flavor dialog
      debug "[compute-service][Flavor] -> new_flavor"
      Compute::Flavor.new(self,params)
    end

    def create_flavor(params)
      debug "[compute-service][Flavor] -> create_flavor -> POST /flavors"
      debug "[compute-service][Flavor] -> create_flavor -> Parameter: #{params}"

      data =  {
        'flavor' => {
        'name'                       => params[:name],
        'ram'                        => params[:ram],
        'vcpus'                      => params[:vcpus],
        'disk'                       => params[:disk],
        'id'                         => params[:flavor_id],
        'swap'                       => params[:swap],
        'OS-FLV-EXT-DATA:ephemeral'  => params[:ephemeral],
        'os-flavor-access:is_public' => params[:is_public],
        'rxtx_factor'                => params[:rxtx_factor]
        }
      }

      api.compute.create_flavor(data).data

    end

    def delete_flavor(id)
      debug "[compute-service][Flavor] -> delete_flavor -> DELETE /flavors/#{id}"
      api.compute.delete_flavor(id)
    end

    def flavors(filter={})
      debug "[compute-service][Flavor] -> flavors -> GET /flavors/detail"
      api.compute.list_flavors_with_details(filter).map_to(Compute::Flavor)
    end
    
    def flavor(flavor_id,use_cache = false)
      debug "[compute-service][Flavor] -> flavor -> GET /flavors/#{flavor_id}"

      flavor_data = nil
      unless use_cache
        flavor_data = api.compute.show_flavor_details(flavor_id).data
        Rails.cache.write("server_flavor_#{flavor_id}",flavor_data, expires_in: 24.hours)
      else
        flavor_data = Rails.cache.fetch("server_flavor_#{flavor_id}", expires_in: 24.hours) do
          api.compute.show_flavor_details(flavor_id).data
        end
      end

      return nil if flavor_data.nil?
      map_to(Compute::Flavor,flavor_data)
    end

    def add_flavor_access_to_tenant(flavor_id,tenant_id)
      debug "[compute-service][Flavor] -> add_flavor_access_to_tenant -> POST /flavors/#{flavor_id}/action"
      api.compute.add_flavor_access_to_tenant_addtenantaccess_action(
        flavor_id,
        "addTenantAccess" => { "tenant" => tenant_id}
      )
    end

    def remove_flavor_access_from_tenant(flavor_id,tenant_id)
      debug "[compute-service][Flavor] -> remove_flavor_access_from_tenant -> POST /flavors/#{flavor_id}/action"
       api.compute.remove_flavor_access_from_tenant_removetenantaccess_action(
        flavor_id,
        "removeTenantAccess" => { "tenant" => tenant_id.to_s }
      )
    end

    def create_flavor_metadata(flavor_id,flavor_extras)
      debug "[compute-service][Flavor] -> create_flavor_metadata -> POST /flavors/#{flavor_id}/os-extra_specs"
      debug "[compute-service][Flavor] -> create_flavor_metadata -> Metadata: #{flavor_extras}"

      api.compute.create_extra_specs_for_a_flavor(flavor_id, 'extra_specs' => flavor_extras).map_to(Compute::FlavorMetadata)
    end

    def delete_flavor_metadata(flavor_id,key)
      debug "[compute-service][Flavor] -> delete_flavor_metadata -> DELETE /flavors/#{flavor_id}/os-extra_specs/#{key}"
      api.compute.delete_an_extra_spec_for_a_flavor(flavor_id, key)
    end

    def flavor_members(flavor_id)
      debug "[compute-service][Flavor] -> flavor_members -> GET /flavors/#{flavor_id}/os-flavor-access"
      api.compute.list_flavor_access_information_for_given_flavor(flavor_id).map_to(Compute::FlavorAccess)
    end

    def flavor_metadata(flavor_id)
      debug "[compute-service][Flavor] -> flavor_metadata -> GET /flavors/#{flavor_id}/os-extra_specs"
      api.compute.list_extra_specs_for_a_flavor(flavor_id).map_to(Compute::FlavorMetadata)
    end

    def new_flavor_metadata(flavor_id)
      debug "[compute-service][Flavor] -> new_flavor_metadata"
      Compute::FlavorMetadata.new(self, flavor_id: flavor_id)
    end

    def new_flavor_access(params = {})
      debug "[compute-service][Flavor] -> new_flavor_access"
      Compute::FlavorAccess.new(self,params)
    end

  end
end
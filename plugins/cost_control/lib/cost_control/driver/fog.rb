require 'fog/openstack/billing'

module CostControl
  module Driver
    class Fog < Interface
      include Core::ServiceLayer::FogDriver::ClientHelper

      PROJECT_METADATA_ATTRMAP = {
        # name in api => name in model
        'name'        => 'project_name',
        'domain'      => 'domain_name',
        'costobject'  => 'cost_object',
        # TODO: 'users' attribute
      }

      def get_project_metadata(project_id)
        handle_response do
          return { "project_name" => "example_project", "domain_name" => "example_domain", "cost_object" => "0123456789" } ## TODO: remove when service is available in staging
          metadata = fog.get_project_metadata(project_id).body['metadata']
          metadata = map_attribute_names(data, PROJECT_METADATA_ATTRMAP)
          metadata['id'] = project_id
          metadata
        end
      end

      def update_project_metadata(project_id, params={})
        handle_response do
          return params ## TODO: remove when service is available in staging
          params = map_attribute_names(params, PROJECT_METADATA_ATTRMAP.invert)
          metadata = fog.put_project_metadata(project_id, params).body['metadata']
          map_attribute_names(metadata, PROJECT_METADATA_ATTRMAP)
        end
      end

      private

      def fog
        @fog ||= ::Fog::Billing::OpenStack.new(auth_params)
      end

      # Rename keys in `data` using the `attribute_map` and delete unknown keys.
      def map_attribute_names(data, attribute_map)
        data.transform_keys { |k| attribute_map.fetch(k, nil) }.reject { |key,_| key.nil? }
      end

    end
  end
end

require 'fog/openstack/billing'

module CostControl
  module Driver
    class Fog < Interface
      include Core::ServiceLayer::FogDriver::ClientHelper

      # TODO: remove (for debugging on staging)
      def handle_response
        yield
      end

      def get_project_metadata(project_id)
        handle_response do
          begin
            metadata = fog.get_project_metadata(project_id).body['metadata']
          rescue ::Fog::Billing::OpenStack::NotFound
            return { 'id' => project_id }
          end
          cost_object = metadata.fetch('cost_object', {})
          {
            'id'               => project_id,
            'cost_object_type' => cost_object['type'],
            'cost_object_id'   => cost_object['name'],
          }
        end
      end

      def update_project_metadata(project_id, params={})
        handle_response do
          metadata = {
            'cost_object' => {
              'type' => params['cost_object_type'],
              'name' => params['cost_object_id'],
            },
          }
          fog.put_project_metadata(project_id, metadata)
          params
        end
      end

      private

      def fog
        @fog ||= ::Fog::Billing::OpenStack.new(
          # this service has only one (public) endpoint
          auth_params.merge(openstack_endpoint_type: 'publicURL'),
        )
      end

    end
  end
end

require 'fog/openstack/billing'

module CostControl
  module Driver
    class Fog < Interface
      include Core::ServiceLayer::FogDriver::ClientHelper

      def get_project_masterdata(project_id)
        handle_response do
          begin
            masterdata = fog.get_project_masterdata(project_id).body['masterdata']
          rescue ::Fog::Billing::OpenStack::NotFound
            return { 'id' => project_id }
          end
          cost_object = masterdata.fetch('cost_object', {})
          {
            'id'               => project_id,
            'cost_object_type' => cost_object.fetch('type', ''),
            'cost_object_id'   => cost_object.fetch('name', ''),
            'cost_object_inherited' => cost_object.fetch('inherited', '')
          }
        end
      end

      def update_project_masterdata(project_id, params={})
        handle_response do
          masterdata = {
            'cost_object' => {
              'type' => params['cost_object_type'],
              'name' => params['cost_object_id'],
              'inherited' => params['cost_object_inherited']
            },
          }
          fog.put_project_masterdata(project_id, masterdata)
          params
        end
      end

      def get_domain_masterdata(domain_id)
        handle_response do
          begin
            masterdata = fog.get_domain_masterdata(domain_id).body['masterdata']
          rescue ::Fog::Billing::OpenStack::NotFound
            return { 'id' => domain_id }
          end
          cost_object = masterdata.fetch('cost_object', {})
          {
              'id'               => domain_id,
              'cost_object_type' => cost_object.fetch('type', ''),
              'cost_object_id'   => cost_object.fetch('name', ''),
              'cost_object_responsibleController' => cost_object.fetch('responsibleController', '')
          }
        end
      end

      def update_domain_masterdata(domain_id, params={})
        handle_response do
          masterdata = {
              'cost_object' => {
                  'type' => params['cost_object_type'],
                  'name' => params['cost_object_id'],
                  'inherited' => params['cost_object_responsibleController']
              },
          }
          fog.put_domain_masterdata(domain_id, masterdata)
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

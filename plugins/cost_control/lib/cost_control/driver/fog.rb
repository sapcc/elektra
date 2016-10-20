require 'fog/billing/openstack'

module CostControl
  module Driver
    class Fog < Interface
      include Core::ServiceLayer::FogDriver::ClientHelper

      def get_project_masterdata(project_id)
        handle_response do
          begin
            masterdata = fog.get_project_masterdata(project_id).body['masterdata']
          rescue ::Fog::Billing::OpenStack::NotFound
            return {'id' => project_id}
          end
          cost_object = masterdata.fetch('cost_object', {})
          {
              'id'                    => project_id,
              'cost_object_type'      => cost_object.fetch('type', ''),
              'cost_object_id'        => cost_object.fetch('name', ''),
              'cost_object_inherited' => cost_object.fetch('inherited', '')
          }
        end
      end

      def update_project_masterdata(project_id, params={})
        if params.fetch('cost_object_inherited', '') == true
          cost_object = {
              'inherited' => params.fetch('cost_object_inherited', '')
          }
        else
          cost_object = {
              'type'      => params.fetch('cost_object_type', ''),
              'name'      => params.fetch('cost_object_id', ''),
              'inherited' => params.fetch('cost_object_inherited', '')
          }

        end
        handle_response do
          masterdata = {
              'cost_object' => cost_object
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
            return {'id' => domain_id}
          end
          cost_object = masterdata.fetch('cost_object', {})
          {
              'id'                                => domain_id,
              'cost_object_type'                  => cost_object.fetch('type', ''),
              'cost_object_id'                    => cost_object.fetch('name', ''),
              'cost_object_responsibleController' => cost_object.fetch('responsibleController', '')
          }
        end
      end

      def update_domain_masterdata(domain_id, params={})
        handle_response do
          masterdata = {
              'cost_object' => {
                  'type'                  => params.fetch('cost_object_type', ''),
                  'name'                  => params.fetch('cost_object_id', ''),
                  'responsibleController' => params.fetch('cost_object_responsibleController', '')
              },
          }
          fog.put_domain_masterdata(domain_id, masterdata)
          params
        end
      end

      def get_kb11n_billing_object(project_id)
        #handle_response do
        begin
          kb11n_billing_object = fog.get_kb11n_billing_object(project: project_id, format: 'json').body
        rescue ::Fog::Billing::OpenStack::NotFound
          return {'id' => project_id}
        end
        kb11n_billing_object = kb11n_billing_object.first
        {
            'id'                                    => project_id,
            'kb11n_billing_object_doc_date'         => kb11n_billing_object.fetch('Doc.date', ''),
            'kb11n_billing_object_doc_headertext'   => kb11n_billing_object.fetch('Doc.headertext', ''),
            'kb11n_billing_object_send_pers_no'     => kb11n_billing_object.fetch('Send.Pers.no', ''),
            'kb11n_billing_object_send_costctr'     => kb11n_billing_object.fetch('Send.CostCtr', ''),
            'kb11n_billing_object_send_order'       => kb11n_billing_object.fetch('Send.Order', ''),
            'kb11n_billing_object_send_sales_order' => kb11n_billing_object.fetch('Send.SalesOrder', ''),
            'kb11n_billing_object_send_sales_item'  => kb11n_billing_object.fetch('Send.SalesItem', ''),
            'kb11n_billing_object_send_wbs'         => kb11n_billing_object.fetch('Send.WBS', ''),
            'kb11n_billing_object_send_network'     => kb11n_billing_object.fetch('Send.Network', ''),
            'kb11n_billing_object_cost_element'     => kb11n_billing_object.fetch('Cost_elem.', ''),
            'kb11n_billing_object_costs'            => kb11n_billing_object.fetch('Costs', ''),
            'kb11n_billing_object_currency'         => kb11n_billing_object.fetch('Tr.Crcy', ''),
            'kb11n_billing_object_quantity'         => kb11n_billing_object.fetch('Quantity', ''),
            'kb11n_billing_object_unit'             => kb11n_billing_object.fetch('Unit', ''),
            'kb11n_billing_object_rec_costctr'      => kb11n_billing_object.fetch('Rec.CostCtr', ''),
            'kb11n_billing_object_rec_order'        => kb11n_billing_object.fetch('Rec.Order', ''),
            'kb11n_billing_object_rec_salesord'     => kb11n_billing_object.fetch('Rec.SalesOrd.', ''),
            'kb11n_billing_object_rec_salesitem'    => kb11n_billing_object.fetch('Rec.SalesItem', ''),
            'kb11n_billing_object_rec_wbs'          => kb11n_billing_object.fetch('Rec.WBS', ''),
            'kb11n_billing_object_rec_network'      => kb11n_billing_object.fetch('Rec.Network', ''),
            'kb11n_billing_object_item_text'        => kb11n_billing_object.fetch('Item_text', '')
        }
        #end
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

module DnsService
  module Driver
    # Compute calls
    class Fog < Interface
      include Core::ServiceLayer::FogDriver::ClientHelper
      
      def initialize(params)
        super(params)
        @fog = ::Fog::DNS::OpenStack::V2.new(auth_params)
      end
      
      def list_zones(filter={})
        handle_response{@fog.list_zones(filter).body['zones']}
      end
      
      def get_zone(id)
        handle_response { @fog.get_zone(id).body }
      end
      
      def list_recordsets(zone_id,options={})
        handle_response{@fog.list_recordsets(zone_id,options).body['recordsets']}
      end
      
      def get_recordset(zone_id,recordset_id)
        handle_response{ @fog.get_recordset(zone_id,recordset_id).body}
      end
      
      def create_recordset(params={})
        handle_response{
          zone_id = params.delete(:zone_id)
          name = params.delete(:name)
          type = params.delete(:type)
          records = params.delete(:records)
          @fog.create_recordset(zone_id, name, type, records, params).body
        }
      end
      
      def update_recordset(id,params={})
        handle_response{
          zone_id = params.delete(:zone_id)
          @fog.update_recordset(zone_id, id, params)
        }
      end
      
      def delete_recordset(zone_id,recordset_id)
        handle_response{ @fog.delete_recordset(zone_id, recordset_id).body }
      end
    end
  end
end
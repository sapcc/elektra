module DnsService
  module Driver
    # Compute calls
    class Fog < Interface
      include Core::ServiceLayer::FogDriver::ClientHelper
      attr_reader :available

      def initialize(params)
        super(params)
        @fog = ::Fog::DNS::OpenStack::V2.new(auth_params)
        @available = true
      rescue ::Fog::OpenStack::Errors::ServiceUnavailable
        @fog = nil
        @available = false
      end

      def list_zones(filter={})
        handle_response{@fog.list_zones(filter).body['zones']}
      end

      def get_zone(id, options = {})
        handle_response { @fog.get_zone(id, options).body }
      end
      
      def create_zone(name, email, options={})
        handle_response{@fog.create_zone(name, email, options).body}
      end
      
      def update_zone(id, attributes={})
        handle_response{@fog.update_zone(id, attributes).body}
      end
      
      def delete_zone(id, options = {})
        handle_response{@fog.delete_zone(id, options).body}
      end

      def list_recordsets(zone_id,options={})
        handle_response{@fog.list_recordsets(zone_id,options).body['recordsets']}
      end

      def get_recordset(zone_id, recordset_id, options = {})
        handle_response{ @fog.get_recordset(zone_id, recordset_id, options).body}
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
          @fog.update_recordset(zone_id, id, params).body
        }
      end

      def delete_recordset(zone_id,recordset_id)
        handle_response{ @fog.delete_recordset(zone_id, recordset_id).body }
      end
    end
  end
end

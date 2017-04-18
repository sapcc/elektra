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

      def delete_recordset(zone_id,recordset_id, options={})
        handle_response{ @fog.delete_recordset(zone_id, recordset_id, options).body }
      end

      #################### ZONE TRANSFER #########################
      def create_zone_transfer_request(options = {})
        zone_id = options.delete(:zone_id)
        handle_response{@fog.create_zone_transfer_request(zone_id, options).body}
      end

      def list_zone_transfer_requests(options={})
        handle_response{@fog.list_zone_transfer_requests(options).body['transfer_requests']}
      end

      def get_zone_transfer_request(id)
        handle_response{@fog.get_zone_transfer_request(id).body}
      end

      def update_zone_transfer_request(id, options = {})
        description = options.delete(:description)
        handle_response{@fog.update_zone_transfer_request(id, description, options).body}
      end

      def delete_zone_transfer_request(id)
        handle_response{@fog.delete_zone_transfer_request(id).body}
      end

      def create_zone_transfer_accept(options={})
        key = options[:key]
        zone_transfer_request_id = options[:zone_transfer_request_id]
        handle_response{@fog.create_zone_transfer_accept(key, zone_transfer_request_id, project_id: options[:target_project_id]).body}
      end

      def list_zone_transfer_accepts(options = {})
        handle_response{@fog.list_zone_transfer_accepts(options).body['transfer_accepts']}
      end

      def get_zone_transfer_accept(id)
        handle_response{@fog.get_zone_transfer_accept(id).body}
      end

      #################### Pools #########################
      def list_pools(filter = {})
        handle_response { @fog.list_pools(filter).body['pools'] }
      end

      def get_pool(id)
        handle_response { @fog.get_pool(id).body }
      end
    end
  end
end

# frozen_string_literal: true

module ServiceLayerNg
  module DnsServiceServices
    # This module implements Openstack Designate Pool API
    module ZoneTransfer
      def zone_transfer_request_map
        @zone_transfer_request_map ||= class_map_proc(DnsService::ZoneTransferRequestNg)
      end

      def zone_transfer_accept_map
        @zone_transfer_accept_map ||= class_map_proc(DnsService::ZoneTransferAcceptNg)
      end

      def zone_transfer_requests(filter = {})
        elektron_dns.get('zones/tasks/transfer_requests', filter).map_to(
          'body.transfer_requests', &zone_transfer_request_map
        )
      end

      def reset_cache_for_zone_transfer_requests
        true
      end

      def new_zone_transfer_request(attributes = {})
        zone_transfer_request_map.call(attributes)
      end

      def find_zone_transfer_request(id)
        elektron_dns.get("zones/tasks/transfer_requests/#{id}").map_to(
          'body', &zone_transfer_request_map
        )
      end

      def zone_transfer_accepts(filter = {})
        response = elektron_dns.get('zones/tasks/transfer_accepts', filter)
        {
          items: response.map_to('body', &zone_transfer_accept_map),
          total: response.body.fetch('metadata', {})['total_count']
        }
      end

      def new_zone_transfer_accept(attributes = {})
        zone_transfer_accept_map.call(attributes)
      end

      def find_zone_transfer_accept(id)
        elektron_dns.get("zones/tasks/transfer_requests/#{id}").map_to(
          'body', &zone_transfer_accept_map
        )
      end

      ################## MODEL INTERFACE #####################
      def create_zone_transfer_request(zone_id, attributes = {})
        elektron_dns.post("zones/#{zone_id}/tasks/transfer_requests") do
          attributes
        end.body
      end

      def update_zone_transfer_request(id, attributes = {})
      end

      def delete_zone_transfer_request(id)
      end

      def create_zone_transfer_accept(attributes = {})
      end
    end
  end
end

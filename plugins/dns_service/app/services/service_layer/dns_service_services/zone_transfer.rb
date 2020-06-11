# frozen_string_literal: true

module ServiceLayer
  module DnsServiceServices
    # This module implements Openstack Designate Pool API
    module ZoneTransfer
      def zone_transfer_request_map
        @zone_transfer_request_map ||= class_map_proc(DnsService::ZoneTransferRequest)
      end

      def zone_transfer_accept_map
        @zone_transfer_accept_map ||= class_map_proc(DnsService::ZoneTransferAccept)
      end

      def zone_transfer_requests(filter = {})
        elektron_dns.get('zones/tasks/transfer_requests', filter).map_to(
          'body.transfer_requests', &zone_transfer_request_map
        )
      end

      def reset_cache_for_zone_transfer_requests
        true
      end

      def new_zone_transfer_request(zone_id, attributes = {})
        zone_transfer_request_map.call(attributes.merge(zone_id: zone_id))
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
        header_options = {}
        if attributes[:source_project_id]
          # this is needed! To be sure that the user can see the zone
          source_project_id = attributes.delete(:source_project_id)
          header_options = {"x-auth-sudo-project-id": source_project_id}
        end

        elektron_dns.post("zones/#{zone_id}/tasks/transfer_requests", headers: header_options) do
          attributes
        end.body
      end

      def update_zone_transfer_request(id, attributes = {})
        elektron_dns.patch("zones/tasks/transfer_requests/#{id}") do
          attributes
        end.body
      end

      def delete_zone_transfer_request(id)
        elektron_dns.delete("zones/tasks/transfer_requests/#{id}")
      end

      def create_zone_transfer_accept(attributes = {})
        project_id = attributes.delete(:target_project_id)
        filter = project_id ? { project_id: project_id } : {}
        elektron_dns.post('zones/tasks/transfer_accepts', filter) do
          attributes
        end.body
      end
    end
  end
end

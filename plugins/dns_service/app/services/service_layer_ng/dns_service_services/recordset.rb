# frozen_string_literal: true

module ServiceLayerNg
  module DnsServiceServices
    # This module implements Openstack Designate Pool API
    module Recordset
      def recordset_map
        @recordset_map ||= class_map_proc(DnsService::RecordsetNg)
      end

      def recordsets(zone_id, filter = {})
        response = elektron_dns.get("zones/#{zone_id}/recordsets", filter)
        {
          items: response.map_to('body.recordsets', &recordset_map),
          total: response.body.fetch('metadata', {}).fetch('total_count', nil)
        }
      end

      def find_recordset(zone_id, recordset_id, filter = {})
        elektron_dns.get(
          "zones/#{zone_id}/recordsets/#{recordset_id}", filter
        ).map_to('body', &recordset_map)
      end

      def new_recordset(attributes = {})
        recordset_map.call(attributes)
      end

      ######################## MODEL INTERFACE ###########################
      def create_recordset(attributes = {})
        zone_id = attributes['zone_id']
        elektron_dns.post("zones/#{zone_id}/recordsets") do
          attributes
        end.body
      end

      def update_recordset(id, attributes = {})
        zone_id = attributes['zone_id']
        elektron_dns.put("zones/#{zone_id}/recordsets/#{id}") do
          attributes
        end.body
      end

      def delete_recordset(id)
        zone_id = attributes['zone_id']
        elektron_dns.delete("zones/#{zone_id}/recordsets/#{id}")
      end
    end
  end
end

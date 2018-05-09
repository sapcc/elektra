# frozen_string_literal: true

module ServiceLayer
  module DnsServiceServices
    # This module implements Openstack Designate Pool API
    module Recordset
      def recordset_map
        @recordset_map ||= class_map_proc(DnsService::Recordset)
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

      def new_recordset(zone_id, attributes = {})
        recordset_map.call(attributes.merge(zone_id: zone_id))
      end

      ######################## MODEL INTERFACE ###########################
      def create_recordset(zone_id, attributes = {})
        elektron_dns.post("zones/#{zone_id}/recordsets") do
          attributes
        end.body
      end

      def update_recordset(zone_id, id, attributes = {})
        project_id = attributes.delete('project_id')
        filter = project_id ? { project_id: project_id } : {}
        elektron_dns.put("zones/#{zone_id}/recordsets/#{id}", filter) do
          attributes
        end.body
      end

      def delete_recordset(zone_id, id, options = {})
        elektron_dns.delete("zones/#{zone_id}/recordsets/#{id}", options)
      end
    end
  end
end

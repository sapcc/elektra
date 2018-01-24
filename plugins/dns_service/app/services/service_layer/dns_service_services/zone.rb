# frozen_string_literal: true

module ServiceLayer
  module DnsServiceServices
    # This module implements Openstack Designate Pool API
    module Zone
      def zone_map
        @zone_map ||= class_map_proc(DnsService::Zone)
      end

      def zones(filter = {})
        response = elektron_dns.get('zones', filter)
        {
          items: response.map_to('body.zones', &zone_map),
          total: response.body.fetch('metadata', {}).fetch('total_count', nil)
        }
      end

      def new_zone(attributes = {})
        zone_map.call(attributes)
      end

      def find_zone!(id, filter = {})
        elektron_dns.get("zones/#{id}", filter).map_to('body', &zone_map)
      end

      def find_zone(id, filter = {})
        find_zone!(id, filter)
      rescue Elektron::Errors::ApiResponse => _e
        nil
      end

      ################### MODEL INTERFACE ####################
      def create_zone(attributes = {})
        elektron_dns.post('zones') do
          attributes
        end.body
      end

      def update_zone(id, attributes = {})
        filter = {}
        filter[:all_projects] = attributes.delete(:all_projects)
        filter[:project_id] = attributes.delete(:project_id)

        elektron_dns.patch("zones/#{id}", filter) do
          attributes
        end.body
      end

      def delete_zone(id, filter = {})
        elektron_dns.delete("zones/#{id}", filter)
      end
    end
  end
end

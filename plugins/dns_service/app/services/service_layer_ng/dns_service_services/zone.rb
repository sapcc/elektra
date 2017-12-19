# frozen_string_literal: true

module ServiceLayerNg
  module DnsServiceServices
    # This module implements Openstack Designate Pool API
    module Zone
      def zone_map
        @zone_map ||= class_map_proc(DnsService::ZoneNg)
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
      end

      def update_zone(id, attributes = {})
      end

      def delete_zone(zone_id, options={})
        driver.map_to(DnsService::Zone).delete_zone(zone_id,options)
      end
    end
  end
end

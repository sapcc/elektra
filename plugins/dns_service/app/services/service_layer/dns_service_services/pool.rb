# frozen_string_literal: true

module ServiceLayer
  module DnsServiceServices
    # This module implements Openstack Designate Pool API
    module Pool
      def pool_map
        @pool_map ||= class_map_proc(DnsService::Pool)
      end

      def pools(filter = {})
        response = elektron_dns.get("pools", filter)
        {
          items: response.map_to("body.pools", &pool_map),
          total: response.body.fetch("metadata", {}).fetch("total_count", nil),
        }
      end

      def find_pool!(id)
        elektron_dns.get("pools/#{id}").map_to("body", &pool_map)
      end

      def find_pool(id)
        find_pool!(id)
      rescue Elektron::Errors::ApiResponse => e
        nil
      end
    end
  end
end

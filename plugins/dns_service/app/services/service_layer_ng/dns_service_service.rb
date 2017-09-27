# frozen_string_literal: true

module ServiceLayerNg
  class DnsServiceService < Core::ServiceLayerNg::Service
    def driver
      @driver ||= DnsService::Driver::Fog.new(
        auth_url:   ::Core.keystone_auth_endpoint,
        region:     region,
        token:      api.token
      )
    end

    def available?(_action_name_sym = nil)
      !current_user.service_url('dns', region: region).nil?
    end

    ################## Pools #####################
    def pools(filter = {})
      #return [] unless current_user.is_allowed?('dns_service:pool_list')
      #Rails.cache.delete("#{api.token}_zone_pools")
      Rails.cache.fetch("#{api.token}_zone_pools", expires_in: 24.hours) do
        driver.map_to(DnsService::Pool).list_pools(filter) rescue []
      end
    end

    def find_pool(id)
      driver.map_to(DnsService::Pool).get_pool(id)
    rescue
      nil
    end
  end
end

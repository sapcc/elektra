module ServiceLayer
  class DnsServiceService < Core::ServiceLayer::Service
    def driver
      @driver ||= DnsService::Driver::Fog.new(
        auth_url:   auth_url,
        region:     region,
        token:      token,
        domain_id:  domain_id,
        project_id: project_id
      )
    end

    def available?(_action_name_sym = nil)
      # driver.available
      !current_user.service_url('designate', region: region).nil?
    end

    def zones(filter = {})
      driver.map_to(DnsService::Zone).list_zones(filter)
    end

    def new_zone(attributes={})
      DnsService::Zone.new(driver, attributes)
    end

    def delete_zone(zone_id, options={})
      driver.map_to(DnsService::Zone).delete_zone(zone_id,options)
    end

    def find_zone(id, options = {})
      driver.map_to(DnsService::Zone).get_zone(id, options)
    end

    def recordsets(zone_id, options = {})
      driver.map_to(DnsService::Recordset).list_recordsets(zone_id, options)
    end

    def find_recordset(zone_id, recordset_id, options = {})
      driver.map_to(DnsService::Recordset).get_recordset(zone_id, recordset_id, options)
    end

    def new_recordset(zone_id, attributes = {})
      DnsService::Recordset.new(driver, attributes.merge(zone_id: zone_id))
    end

    def delete_recordset(zone_id, id, options = {})
      driver.delete_recordset(zone_id, id, options)
    end

    ################## ZONE TRANSFER #####################
    def zone_transfer_requests(options={})
      Rails.cache.fetch("#{project_id}_zone_transfer_requests_#{options.to_s}", expires_in: 1.hours) do
        driver.map_to(DnsService::ZoneTransferRequest).list_zone_transfer_requests(options)
      end

      #driver.map_to(DnsService::ZoneTransferRequest).list_zone_transfer_requests(options)
    end

    def reset_cache_for_zone_transfer_requests
      Rails.cache.delete_matched("zone_transfer_requests_*")
    end

    def new_zone_transfer_request(zone_id,attributes={})
      DnsService::ZoneTransferRequest.new(driver,attributes.merge(zone_id: zone_id))
    end

    def find_zone_transfer_request(id)
      driver.map_to(DnsService::ZoneTransferRequest).get_zone_transfer_request(id)
    end

    def zone_transfer_accepts(options={})
      driver.map_to(DnsService::ZoneTransferAccept).list_zone_transfer_accepts(options)
    end

    def new_zone_transfer_accept(attributes={})
      DnsService::ZoneTransferRequest.new(driver,attributes)
    end

    def find_zone_transfer_accept(id)
      driver.map_to(DnsService::ZoneTransferAccept).get_zone_transfer_accept(id)
    end

    ################## Pools #####################
    def pools(filter = {})
      #return [] unless current_user.is_allowed?('dns_service:pool_list')
      Rails.cache.fetch("#{project_id}_zone_pools", expires_in: 24.hours) do
        driver.map_to(DnsService::Pool).list_pools(filter) rescue []
      end

    end

    def find_pool(id)
      driver.map_to(DnsService::Pool).get_pool(id) rescue nil
    end
  end
end

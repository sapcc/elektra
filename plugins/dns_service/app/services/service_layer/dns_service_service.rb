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
      driver.available
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
  end
end

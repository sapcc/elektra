module DnsService
  class ZonesController < ApplicationController
    def index
      @zones = services.dns_service.zones
    end
    
    def show
      @zone = services.dns_service.find_zone(params[:id])
      
      @recordsets = paginatable(per_page: 20) do |pagination_options|
        services.dns_service.recordsets(params[:id], {sort_key: 'name'}.merge(pagination_options))
      end

      @nameservers = services.dns_service.recordsets(params[:id], type: 'NS')
    end
  end
end
module DnsService
  class ZonesController < ApplicationController
    def index
      @zones = services.dns_service.zones
    end
    
    def show
      @zone = services.dns_service.find_zone(params[:id])
      @recordsets = services.dns_service.recordsets(params[:id])
    end
  end
end
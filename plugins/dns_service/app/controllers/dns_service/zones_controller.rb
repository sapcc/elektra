module DnsService
  class ZonesController < ApplicationController
    before_filter ->(id = params[:id]) { load_zone id }, except: [:index]

    def index
      @zones = services.dns_service.zones(@admin_option)
    end

    def show
      @recordsets = paginatable(per_page: 20) do |pagination_options|
        services.dns_service.recordsets(
          {
            zone_id: params[:id],
            sort_key: 'name'
          }.merge(@impersonate_option).merge(pagination_options)
        )
      end

      @nameservers = services.dns_service.recordsets(
        {
          zone_id: params[:id],
          type: 'NS'
        }.merge(@impersonate_option)
      )
    end
  end
end

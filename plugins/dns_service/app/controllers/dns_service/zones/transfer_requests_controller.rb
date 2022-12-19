module DnsService
  module Zones
    class TransferRequestsController < DnsService::ApplicationController
      def index
        @zone_transfer_requests =
          services
            .dns_service
            .zone_transfer_requests(status: "ACTIVE")
            .select do |r|
              r.project_id.nil? or r.project_id != @scoped_project_id
            end
      end

      def new
        @zone_transfer_request =
          services
            .dns_service
            .zone_transfer_requests(status: "ACTIVE")
            .find { |zt| zt.zone_id == params[:zone_id] } ||
            services.dns_service.new_zone_transfer_request(params[:zone_id])
      end

      def create
        @zone_transfer_request =
          services.dns_service.new_zone_transfer_request(
            params[:zone_id],
            params[:zone_transfer_request],
          )
        if @zone_transfer_request.save
          services.dns_service.reset_cache_for_zone_transfer_requests
        end
      end

      def destroy
        @zone_transfer_request =
          services.dns_service.new_zone_transfer_request(
            params[:zone_id],
            { id: params[:id] },
          )
        if @zone_transfer_request.destroy
          @zone_transfer_request.id = nil
          services.dns_service.reset_cache_for_zone_transfer_requests
        end
      end

      def accept
        @zone_transfer_request =
          services.dns_service.new_zone_transfer_request(nil)
        @zone_transfer_request.id = params[:id]
        @zone_transfer_request.key = params[:key]
        if @zone_transfer_request.accept
          services.dns_service.reset_cache_for_zone_transfer_requests
        end
      end
    end
  end
end

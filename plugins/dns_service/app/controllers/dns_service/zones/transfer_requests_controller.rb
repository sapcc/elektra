module DnsService
  module Zones
    class TransferRequestsController < DnsService::ApplicationController
      def index
        @zone_transfer_requests = services.dns_service.zone_transfer_requests(status: 'ACTIVE')
      end

      def new
        @zone_transfer_request = services.dns_service.zone_transfer_requests(status: 'ACTIVE').find do |zt|
          zt.zone_id==params[:zone_id]
        end || services.dns_service.new_zone_transfer_request(params[:zone_id])
      end

      def create
        @zone_transfer_request = services.dns_service.new_zone_transfer_request(
          params[:zone_id], params[:zone_transfer_request]
        )
        @project = service_user.find_project_by_name_or_id(@zone_transfer_request.target_project_id)
        if @project
          @zone_transfer_request.target_project_id=@project.id
          #@zone_transfer_request.project_id = @scoped_project_id
          @zone_transfer_request.save
        else
          @zone_transfer_request.errors.add(:target_project_id, 'Could not find project.')
        end

      end

      def destroy
        @zone_transfer_request = services.dns_service.new_zone_transfer_request(
          params[:zone_id], {id: params[:id]}
        )
        if @zone_transfer_request.destroy
          @zone_transfer_request.id=nil
        end
      end

      def accept
        @zone_transfer_request = services.dns_service.new_zone_transfer_request(nil)
        @zone_transfer_request.id = params[:id]
        @zone_transfer_request.key= params[:key]
        @zone_transfer_request.accept
      end

    end
  end
end

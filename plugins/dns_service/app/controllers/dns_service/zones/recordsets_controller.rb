module DnsService
  module Zones
    class RecordsetsController < ApplicationController
      def show
        @recordset = services.dns_service.find_recordset(params[:zone_id],params[:id])
      end
      
      def new
        @zone = services.dns_service.find_zone(params[:zone_id])
        @recordset = services.dns_service.new_recordset(@zone.id)
      end
      
      def create
        @zone = services.dns_service.find_zone(params[:zone_id])
        @recordset = services.dns_service.new_recordset(@zone.id, params[:recordset])
        @recordset.zone_name = @zone.name
        if @recordset.save
          flash.now[:notice] = "Recordset successfully created."
          redirect_to zone_path(@zone.id)
        else
          render action: :new
        end
      end
      
      def destroy
        @deleted = services.dns_service.delete_recordset(params[:zone_id],params[:id])
        respond_to do |format|
          format.js{}
          format.html{redirect_to zone_path(id:params[:zone_id],page: params[:page],marker: params[:marker])  }
        end
      end
    end
  end
end
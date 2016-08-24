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
      
      def edit
        @zone = services.dns_service.find_zone(params[:zone_id])
        @recordset = services.dns_service.find_recordset(@zone.id,params[:id])
      end
      
      def update
        @zone = services.dns_service.find_zone(params[:zone_id])
        @recordset = services.dns_service.find_recordset(@zone.id,params[:id])
        
        @recordset.records = params[:recordset][:records]
        @recordset.description = params[:recordset][:description]
        @recordset.ttl = params[:recordset][:ttl]

        if @recordset.save
          flash.now[:notice] = "Recordset successfully updated."
          respond_to do |format|
            format.html{redirect_to zone_path(@zone.id)}
            format.js {render 'update.js'}
          end
          
        else
          render action: :edit
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
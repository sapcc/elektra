module DnsService
  module Zones
    class RecordsetsController < DnsService::ApplicationController
      before_filter ->(id = params[:zone_id]) { load_zone id }
      def show
        @recordset = services.dns_service.find_recordset(params[:zone_id], params[:id], @impersonate_option)
      end

      def new
        @recordset = services.dns_service.new_recordset(@zone.id, @impersonate_option)
      end

      def create
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
        @recordset = services.dns_service.find_recordset(@zone.id, params[:id], @impersonate_option)
      end

      def update
        @recordset = services.dns_service.find_recordset(@zone.id, params[:id], @impersonate_option)

        @recordset.records = params[:recordset][:records]
        @recordset.description = params[:recordset][:description]
        @recordset.ttl = params[:recordset][:ttl]
        # only impersonate other project if allowed
        @recordset.project_id = nil unless @all_projects

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
        @deleted = services.dns_service.delete_recordset(params[:zone_id], params[:id], @impersonate_option)
        respond_to do |format|
          format.js{}
          format.html{redirect_to zone_path(id:params[:zone_id],page: params[:page],marker: params[:marker])  }
        end
      end
    end
  end
end

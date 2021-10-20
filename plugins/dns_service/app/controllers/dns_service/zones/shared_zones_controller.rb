module DnsService
  module Zones
    class SharedZonesController < DnsService::ApplicationController

      def index
        @shared_zones = services.dns_service.shared_zones()
        @zone = services.dns_service.find_zone(params[:zone_id], all_projects: @all_projects)
      end

      def new
        @shared_zone = services.dns_service.new_shared_zone
      end

      def create

        zone_id = params[:zone_id] || nil
        target_project_id = params[:shared_zone][:target_project_id] || nil
        @shared_zone = services.dns_service.new_shared_zone(target_project_id: target_project_id, zone_id: zone_id)

        if @shared_zone.save 
          flash.now[:notice] = "Zone was successfully shared."
          respond_to do |format|
            format.html{redirect_to zones_url}
          end
        else
          render action: :new
        end

      end

    end
  end
end
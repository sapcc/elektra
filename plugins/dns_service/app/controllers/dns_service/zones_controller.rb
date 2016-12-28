module DnsService
  class ZonesController < DnsService::ApplicationController
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

    def new
      @zone = services.dns_service.new_zone
    end

    def create
      @zone = services.dns_service.new_zone(params[:zone])
      if @zone.save
        flash.now[:notice] = "Zone successfully created."
        respond_to do |format|
          format.html{redirect_to zones_url}
          format.js {render 'create.js'}
        end
      else
        render action: :new
      end
    end

    def edit
      @zone = services.dns_service.find_zone(params[:id])
    end

    def update
      @zone = services.dns_service.find_zone(params[:id])
      @zone.attributes=params[:zone]
      if @zone.save
        flash.now[:notice] = "Zone successfully updated."
        respond_to do |format|
          format.html{redirect_to zones_url}
          format.js {render 'update.js'}
        end
      else
        render action: :edit
      end
    end

    def destroy
      @zone = services.dns_service.delete_zone(params[:id])
      respond_to do |format|
        format.js{}
        format.html{redirect_to zones_url  }
      end
    end

  end
end

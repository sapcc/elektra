module DnsService
  class ZonesController < DnsService::ApplicationController
    before_action ->(id = params[:id]) { load_zone id }, except: %i[index]
    before_action :load_pools, only: %i[index show update create new]

    authorization_context 'dns_service'
    authorization_required

    def index
      per_page = params[:per_page] || 20

      filter = {}
      @search = nil
      @searchfor = nil

      if params.include?(:search)
        if not params[:search].blank?
          @search = params[:search]
          @searchfor = "#{params[:searchfor]}"
          filter = {@searchfor.downcase() => @search}
        else
          params.delete(:search)
          params.delete(:searchfor)
        end
      end

      @zones = paginatable(per_page: per_page.to_i) do |pagination_options|
        services.dns_service.zones(
          @admin_option.merge(pagination_options).merge(filter)
        )[:items]
      end
      services.dns_service.shared_zones()

      active_requests = services.dns_service.zone_transfer_requests(status: 'ACTIVE')

      @zone_transfer_requests = active_requests.select do |r|
        r.project_id.nil? or r.project_id != @scoped_project_id
      end

      @active_zone_transfer_requests = active_requests.inject({}) do |hash,r|
        hash[r.zone_id] = r if r.project_id == @scoped_project_id
        hash
      end

      # this is relevant in case an ajax paginate call is made.
      # in this case we don't render the layout, only the list!
      if request.xhr?
        render partial: 'list', locals: { zones: @zones, active_zone_transfer_requests: @active_zone_transfer_requests, pools: @pools}
      else
        # comon case, render index page with layout
        render action: :index
      end
    end

    def show

      per_page = params[:per_page] || 20

      filter = {}
      @search = nil
      @searchfor = nil

      if params.include?(:search)
        if not params[:search].blank?
          @search = params[:search]
          @searchfor = "#{params[:searchfor]}"
          filter = {@searchfor.downcase() => @search}
        else
          params.delete(:search)
          params.delete(:searchfor)
        end
      end

      @zone = services.dns_service.find_zone(params[:id], all_projects: @all_projects)

      @recordsets = paginatable(per_page: per_page.to_i) do |pagination_options|
        services.dns_service.recordsets(
          params[:id],
          {
            sort_key: 'name'
          }.merge(@impersonate_option).merge(pagination_options).merge(filter)
        )[:items]
      end

      ns_options = { type: 'NS' }
      ns_options[:name] = @zone.name if @zone

      @nameservers = services.dns_service.recordsets(
        params[:id],
        ns_options.merge(@impersonate_option)
      )[:items]

      # this is relevant in case an ajax paginate call is made.
      # in this case we don't render the layout, only the list!
      if request.xhr?
        zone = services.dns_service.find_zone(params[:id], @impersonate_option)
        render partial: 'dns_service/zones/recordsets/recordsets', locals: { recordsets: @recordsets, zone: zone }
      else
        # comon case, render index page with layout
        render action: :show
      end
    end

    def new
      @zone = services.dns_service.new_zone
    end

    def create

      # check for existing zone
      zone_name = params[:zone][:name]
      @zone = services.dns_service.zones(name: zone_name)[:items].first
      if @zone
        @zone.errors.add('Error', 'Zone already existing')
        render action: :new
        return
      else
        @zone = services.dns_service.new_zone(params[:zone])
      end

      update_limes_data(@scoped_domain_id, @scoped_project_id)
      # check that subzones are not exsisting in other projects 
      zone_transfer = check_parent_zone(zone_name,@scoped_project_id)
      # check and increase zone quota for destination project 
      check_and_increase_quota(@scoped_domain_id, @scoped_project_id, 'zones')
      # make sure that recordset quota is increased at least by 2 as there are two recrodsets are created (NS + SOA)
      check_and_increase_quota(@scoped_domain_id, @scoped_project_id, 'recordsets', 2)

      if @zone.save

        # if zone_transfer
        #   # try to find existing zone transfer request
        #   @zone_transfer_request = services.dns_service.zone_transfer_requests(
        #     status: 'ACTIVE'
        #   ).select do |zone_transfer_request|
        #     zone_transfer_request.target_project_id == @scoped_project_id &&
        #       zone_transfer_request.zone_id == @zone.id
        #   end.first

        #   # create a new zone transfer request if not exists
        #   @zone_transfer_request ||= services.dns_service.new_zone_transfer_request(
        #     @zone.id, target_project_id: @scoped_project_id, source_project_id: @zone.project_id
        #   )
        #   @zone_transfer_request.description = "create new zone via elektra"

        #   unless @zone_transfer_request.save && @zone_transfer_request.accept(@scoped_project_id)
        #     # catch errors for transfer zone request
        #     @zone_transfer_request.errors.each { |k, m| @zone_request.errors.add(k,m) }
        #   end
        # end

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
    end

    def update
      @zone.attributes = params[:zone].merge(@impersonate_option)

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
      # TODO: if zone cannot be deleted like subzones are existing the error is not handled
      @deleted = services.dns_service.delete_zone(params[:id], @impersonate_option)
      respond_to do |format|
        format.js {}
        format.html { redirect_to zones_url }
      end
    end

    private

    def load_pools
      @pools = []
      return unless current_user.is_allowed?("dns_service:pool_list")
      @pools = services.dns_service.pools[:items]
    end
  end
end

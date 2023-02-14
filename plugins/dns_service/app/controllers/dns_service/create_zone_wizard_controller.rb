module DnsService
  class CreateZoneWizardController < ::DashboardController
    before_action :load_inquiry
    include CreateZonesHelper

    def new
      @zone_request = ::DnsService::ZoneRequest.new(nil)
      return if @inquiry.nil?
      payload = @inquiry.payload
      @zone_request.attributes = payload
      @pool = load_pool(@zone_request.domain_pool)

      if @inquiry
        scraped_at =
          begin
            cloud_admin
              .resource_management
              .find_project(
                @inquiry.domain_id,
                @inquiry.project_id,
                service: "dns",
                resource: "zones",
              )
              .services
              .first
              .scraped_at
          rescue StandardError
            0
          end

        # sync if last sync was more than 5 minutes ago
        if (Time.now.to_i - scraped_at.to_i) > 300
          Thread.new do
            cloud_admin.resource_management.sync_project_asynchronously(
              @inquiry.domain_id,
              @inquiry.project_id,
            )
          end
        end
      end
    end

    def create
      @zone_request = ::DnsService::ZoneRequest.new(nil, params[:zone_request])
      # try to find zone with given name, if nil create a new one
      @zone =
        services.dns_service.zones(name: @zone_request.zone_name)[:items].first
      @pool = load_pool(@zone_request.domain_pool)

      if @zone
        @zone_request.errors.add(
          "Error",
          "requested zone #{@zone_request.zone_name} already exist in project #{@zone.project_id}",
        )
        render action: :new
        return
      else
        # create new zone if it does not already exist
        @zone ||= services.dns_service.new_zone(@zone_request.attributes)
        @zone.name = @zone_request.zone_name
        pool_attrs = @pool.read("attributes")
        @zone.write("attributes", pool_attrs)
      end

      update_limes_data(@inquiry.domain_id, @inquiry.project_id)
      # check for subzones that they are not exsisting in other projects
      # zone_transfer = true -> if subzone exist in other project, than we need to create the zone there and transfer it to the source project
      # zone_transfer = false -> all subzones already existing in the source project
      zone_transfer =
        check_parent_zone(@zone_request.zone_name, @inquiry.project_id)
      # check and increase zone quota for destination project
      check_and_increase_quota(@inquiry.domain_id, @inquiry.project_id, "zones")
      # make sure that recordset quota is increased at least by 2 as there are two recrodsets are created (NS + SOA)
      check_and_increase_quota(
        @inquiry.domain_id,
        @inquiry.project_id,
        "recordsets",
        2,
      )

      # catch errors from limes api
      unless @zone_request.errors.empty?
        render action: :new
        return
      end

      if @zone.save
        # we need zone transfer if the domain was created in cloud-admin project
        if zone_transfer
          # try to find existing zone transfer request
          @zone_transfer_request =
            services
              .dns_service
              .zone_transfer_requests(status: "ACTIVE")
              .select do |zone_transfer_request|
                zone_transfer_request.target_project_id ==
                  @inquiry.project_id &&
                  zone_transfer_request.zone_id == @zone.id
              end
              .first

          # create a new zone transfer request if not exists
          @zone_transfer_request ||=
            services.dns_service.new_zone_transfer_request(
              @zone.id,
              target_project_id: @inquiry.project_id,
              source_project_id: @zone.project_id,
            )
          @zone_transfer_request.description = "approve zone-request workflow"

          #approve zone transfer to destination project
          if @zone_transfer_request.save &&
               @zone_transfer_request.accept(@inquiry.project_id)
            if @inquiry
              services.inquiry.set_inquiry_state(
                @inquiry.id,
                :approved,
                "Domain #{@zone.name} approved and created by #{current_user.full_name}",
                current_user,
              )
            end
          else
            # catch errors for transfer zone request
            @zone_transfer_request.errors.each do |k, m|
              @zone_request.errors.add(k, m)
            end
          end
        else
          # everything went fine set workflow to approved
          if @inquiry
            services.inquiry.set_inquiry_state(
              @inquiry.id,
              :approved,
              "Domain #{@zone.name} approved and created by #{current_user.full_name}",
              current_user,
            )
          end
        end
      else
        # catch errors for zone update
        @zone.errors.each { |k, m| @zone_request.errors.add(k, m) }
      end

      if @zone_request.errors.empty?
        # render create.js.erb
        render action: :create
      else
        render action: :new
      end
    end

    protected

    def load_inquiry
      return if params[:inquiry_id].blank?
      @inquiry = services.inquiry.get_inquiry(params[:inquiry_id])
    end

    def load_pool(pool_id)
      cloud_admin.dns_service.find_pool(pool_id)
    end
  end
end

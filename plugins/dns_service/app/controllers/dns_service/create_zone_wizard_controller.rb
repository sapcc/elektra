module DnsService
  class CreateZoneWizardController < ::DashboardController
    before_action :load_inquiry

    def new
      @zone_request = ::DnsService::ZoneRequest.new(nil)
      return if @inquiry.nil?
      payload = @inquiry.payload
      @zone_request.attributes = payload
      @pool = load_pool(@zone_request.domain_pool)

      if @inquiry
        scraped_at = cloud_admin.resource_management.find_project(
          @inquiry.domain_id,
          @inquiry.project_id,
          service: 'dns',
          resource: 'zones'
        ).services.first.scraped_at rescue 0

        # sync if last sync was more than 5 minutes ago
        if (Time.now.to_i - scraped_at.to_i) > 300
          Thread.new {
            cloud_admin.resource_management.sync_project_asynchronously(
              @inquiry.domain_id, @inquiry.project_id
            )
          }
        end
      end
    end

    def create
      zone_transfer = true
      @zone_request = ::DnsService::ZoneRequest.new(nil, params[:zone_request])
      # try to find zone with given name, if nil create a new one
      @zone = services.dns_service.zones(name: @zone_request.zone_name)[:items].first
      # create new zone if it does not already exist
      @zone ||= services.dns_service.new_zone(@zone_request.attributes)
      @zone.name = @zone_request.zone_name
      @pool = load_pool(@zone_request.domain_pool)
      pool_attrs = @pool.read('attributes')
      @zone.write('attributes', pool_attrs)

      dns_domain = @zone_request.dns_domain || ""
      external = @zone_request.external || false

      # check that the requested zone is not a subzone from an existing zone in the destination project
      # get all zones from destination project
      project_zones =  services.dns_service.zones(project_id: @inquiry.project_id)[:items]

      project_zones.each do |project_zone|
        if dns_domain != ""
          # filter dns_domain
          requested_zone_name = @zone.name.gsub("#{dns_domain}.","")
          project_zone_name = project_zone.name.gsub("#{dns_domain}.","")
        else
          requested_zone_name = @zone.name
          project_zone_name = project_zone.name
        end
        
        if requested_zone_name == project_zone_name
            @zone_request.errors.add('Error',"requested zone #{requested_zone_name} already exist")
            render action: :new
            return
        end

        # is the requested zone part of exsiting zone inside the project?
        requested_parent_zone_name = requested_zone_name.partition('.').last
        while requested_parent_zone_name != ""
          if ( project_zone_name == requested_parent_zone_name ) && ( @inquiry.project_id == project_zone.project_id )
            puts "requested zone #{requested_zone_name} is part of existing zone #{requested_parent_zone_name} inside the destination project #{project_zone.project_id}"
            # zone will be created inside the project
            @zone.project_id(@inquiry.project_id)
            # no zone transfer is needed
            zone_transfer = false
          end
          requested_parent_zone_name = requested_parent_zone_name.partition('.').last
        end
      end

      # get dns zones quota for target project
      dns_zone_resource = cloud_admin.resource_management.find_project(
        @inquiry.domain_id, @inquiry.project_id,
        service: 'dns',
        resource: 'zones',
      ).resources.first or raise ActiveRecord::RecordNotFound

      if dns_zone_resource.quota == 0 || dns_zone_resource.quota <= dns_zone_resource.usage
        unless dns_zone_resource.quota < dns_zone_resource.usage
          # standard increase quota +1
          dns_zone_resource.quota += 1
        else
          # special case if quota is smaller than usage than adjust quota to usage plus 1
          dns_zone_resource.quota = dns_zone_resource.usage + 1
        end
        unless dns_zone_resource.save
           # catch error for automatic zone quota adjustment
           dns_zone_resource.errors.each { |k, m| @zone_request.errors.add(k,m) }
           render action: :new
           return
        end
      end

      if @zone.save
        # we need zone transfer if the domain was created in cloud-admin project
        if zone_transfer
          # try to find existing zone transfer request
          @zone_transfer_request = services.dns_service.zone_transfer_requests(
            status: 'ACTIVE'
          ).select do |zone_transfer_request|
            zone_transfer_request.target_project_id == @inquiry.project_id &&
              zone_transfer_request.zone_id == @zone.id
          end.first

          # create a new zone transfer request if not exists
          @zone_transfer_request ||= services.dns_service.new_zone_transfer_request(
            @zone.id, target_project_id: @inquiry.project_id
          )

          if @zone_transfer_request.save && @zone_transfer_request.accept(@inquiry.project_id)
            if @inquiry
              services.inquiry.set_inquiry_state(
                @inquiry.id, :approved,
                "Domain #{@zone.name} approved and created by #{current_user.full_name}",
                current_user
              )
            end
          else
            # catch errors for transfer zone request
            @zone_transfer_request.errors.each { |k, m| @zone_request.errors.add(k,m) }
          end
        else
          if @inquiry
            services.inquiry.set_inquiry_state(
              @inquiry.id, :approved,
              "Domain #{@zone.name} approved and created by #{current_user.full_name}",
              current_user
            )
          end
        end

      else
        # catch errors for zone update
        @zone.errors.each{|k,m| @zone_request.errors.add(k,m)}
      end

      if @zone_request.errors.empty?
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

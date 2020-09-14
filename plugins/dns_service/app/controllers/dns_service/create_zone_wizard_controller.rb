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
      @pool = load_pool(@zone_request.domain_pool)

      if @zone
        @zone_request.errors.add('Error',"requested zone #{@zone_request.zone_name} already exist in project #{@zone.project_id}")
        render action: :new
        return
      else
        # create new zone if it does not already exist
        @zone ||= services.dns_service.new_zone(@zone_request.attributes)
        @zone.name = @zone_request.zone_name
        pool_attrs = @pool.read('attributes')
        @zone.write('attributes', pool_attrs)
      end

      # check that subzones are not exsisting in other projects
      # Example: bla.only.sap
      # 0) check finds that the zone "only.sap" exists not in the destination project
      # 1) than the new zone "bla.only.sap" needs to be created created in the project where "only.sap" is located (ccadmin/master)
      # 2) and than transfered to the destination project
      # Example: foo.bla.only.sap
      # 0) check finds that zone bla.only.sap is existing in the same project
      # 1) the new zone is created directly in the destination project
      requested_parent_zone_name = @zone_request.zone_name.partition('.').last
      while requested_parent_zone_name != ""
        # first, check that parent zones of the requested zone are not a existing zone inside the destination project?
        requested_parent_zone = services.dns_service.zones(project_id: @inquiry.project_id, name: requested_parent_zone_name)[:items].first
        unless requested_parent_zone
          # second, check that parent zones of the requested zone are not a existing zone inside another project?
          requested_parent_zone = services.dns_service.zones(all_projects: true, name: requested_parent_zone_name)[:items].first
        end
        if requested_parent_zone
          if requested_parent_zone.project_id == @inquiry.project_id
            puts "requested zone #{@zone_request.zone_name} is part of existing zone #{requested_parent_zone_name} inside the destination project #{@inquiry.project_id}"
            # zone will be created in the destination project
            @zone.project_id(@inquiry.project_id)
            # no zone transfer is needed
            zone_transfer = false
            break
          else
            puts "requested zone #{@zone_request.zone_name} is part of existing zone #{requested_parent_zone_name} inside the project #{requested_parent_zone.project_id}"
            # this is usualy the case if we found "only.sap" or "c.REGION-cloud.sap" that lives in the ccadmin/master project

            # 0. find project to get domain_id
            requested_parent_zone_project = services.identity.find_project(requested_parent_zone.project_id)
            # 1. check zone quota for requested_parent_zone project where the zone is first created that their is in any case enough zone quota free
            check_and_increase_quota(requested_parent_zone_project.domain_id, requested_parent_zone.project_id, 'zones')
            # 2. zone will be created inside the project where the parent zone lives
            @zone.project_id(requested_parent_zone.project_id)
            # 3. zone transfer to destination project is needed
            zone_transfer = true
            break
          end
        end
        requested_parent_zone_name = requested_parent_zone_name.partition('.').last
      end

      # check and increase zone quota for destination project 
      check_and_increase_quota(@inquiry.domain_id, @inquiry.project_id, 'zones')
      # make sure that recordset quota is increased at least by 2 as there are two recrodsets are created (NS + SOA)
      check_and_increase_quota(@inquiry.domain_id, @inquiry.project_id, 'recordsets', 2)

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
            @zone.id, target_project_id: @inquiry.project_id, source_project_id: @zone.project_id
          )
          @zone_transfer_request.description = "approve zone-request workflow"

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

    def check_and_increase_quota(domain_id,project_id,resource,increase = 1)
      # get dns quota for resource and target project
      dns_resource = cloud_admin.resource_management.find_project(
        domain_id, project_id,
        service: 'dns',
        resource: resource,
      ).resources.first or raise ActiveRecord::RecordNotFound

      if dns_resource.quota == 0 || dns_resource.usable_quota <= dns_resource.usage
        unless dns_resource.usable_quota < dns_resource.usage
          # standard increase quota plus increase value
          dns_resource.quota += increase
        else
          # special case if usable quota is smaller than usage than adjust new quota to usage plus increase value
          dns_resource.quota = dns_resource.usage + increase
        end
        unless dns_resource.save
           # catch error for automatic quota adjustment
           dns_resource.errors.each { |k, m| @zone_request.errors.add(k,m) }
           render action: :new
           return
        end
      end
    end
  end
end

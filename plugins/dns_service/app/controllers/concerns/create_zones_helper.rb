# frozen_string_literal: true
module CreateZonesHelper

  def check_parent_zone(zone_name,destination_project_id)
    zone_transfer = true
    # check that subzones are not exsisting in other projects
    # Example: bla.only.sap
    # 0) check finds that the zone "only.sap" exists not in the destination project
    # 1) than the new zone "bla.only.sap" needs to be created created in the project where "only.sap" is located (ccadmin/master)
    # 2) and than transfered to the destination project
    # Example: foo.bla.only.sap
    # 0) check finds that zone bla.only.sap is existing in the same project
    # 1) the new zone is created directly in the destination project
    requested_parent_zone_name = zone_name.partition('.').last
    while requested_parent_zone_name != ""
      # first, check that parent zones of the requested zone are not a existing zone inside the destination project?
      requested_parent_zone = services.dns_service.zones(project_id: destination_project_id, name: requested_parent_zone_name)[:items].first
      unless requested_parent_zone
        # second, check that parent zones of the requested zone are not a existing zone inside another project?
        requested_parent_zone = services.dns_service.zones(all_projects: true, name: requested_parent_zone_name)[:items].first
      end
      if requested_parent_zone
        if requested_parent_zone.project_id == destination_project_id
          puts "requested zone #{zone_name} is part of existing zone #{requested_parent_zone_name} inside the destination project #{destination_project_id}"
          # zone will be created in the destination project
          @zone.project_id(destination_project_id)
          # no zone transfer is needed
          zone_transfer = false
          break
        else
          puts "requested zone #{zone_name} is part of existing zone #{requested_parent_zone_name} inside the project #{requested_parent_zone.project_id}"
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
    return zone_transfer
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

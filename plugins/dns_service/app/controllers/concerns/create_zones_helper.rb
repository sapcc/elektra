# frozen_string_literal: true
module CreateZonesHelper

  def create_zone(zone_name,attributes, domain_id, project_id)
    # find the project id of this zone name
    target_project = find_parent_zone_project(zone_name, project_id)
    
    zone = services.dns_service.zones(name: zone_name)[:items].first
    if zone
      zone.errors.add("Error", "Zone already existing")
      return zone
    else
      adjust_resource_limits(
        domain_id, project_id, target_project&.domain_id, target_project&.id
      )

      pool = cloud_admin.dns_service.find_pool(attributes[:domain_pool])
      pool_attrs = pool.read("attributes")
      zone = services.dns_service.new_zone(attributes)
      zone.name = zone_name
      zone.write("attributes", pool_attrs)
    end
    zone.project_id(target_project&.id)

    if zone.save
      errors = transfer_zone_if_needed(zone, project_id, target_project&.id)
      if errors&.present? 
        errors.each do |error|
          zone.errors.add("Zone Transfer",error)
        end
      end 
    end

    if zone.id.nil?
      zone.errors.add("Error","Zone could not be created")
    end

    return zone
  end

  # this method tries to find the project for a given zone name
  # We call the project that owns the zone the parent project.
  # The parent project can be either current project or any other project.
  def find_parent_zone_project(zone_name, source_project_id) 
    # cut off the first part of the zone name
    requested_parent_zone_name = zone_name.partition(".").last

    # do this until the zone name is empty
    while requested_parent_zone_name != ""
      # first, try to find the parent zone in the same project
      parent_zone = services.dns_service.zones(
        project_id: source_project_id,
        name: requested_parent_zone_name,
      )[
        :items
      ].first

      # if not found, try to find the parent zone in any other project
      if parent_zone.nil?
        parent_zone = services.dns_service.zones(
          all_projects: true,
          name: requested_parent_zone_name,
        )[
          :items
        ].first
      end
      # if found, return the project of the parent zone
      if !parent_zone.nil?
        return services.identity.find_project(parent_zone.project_id)
      end
      # if not found, cut off the next part of the zone name and try again
      requested_parent_zone_name = requested_parent_zone_name.partition(".").last
    end
  end
  
  # this method checks the zone and recordset limits of the project
  # and increases them if needed.
  # If target project is different from this project, the zone has 
  # to be created in the target project and then transferred to this project.
  # For this, the limitis for zone of target project and this project should be checked
  # and increased if needed. Additionally, the recordset limits of this project 
  # should be checked and increased if needed. 
  def adjust_resource_limits(
    source_domain_id,
    source_project_id,
    target_domain_id,
    target_project_id)
    # first, get the latests state of the limes data for this project
    update_limes_data(source_domain_id,source_project_id)
    
    # update zone limits for this project if needed
    check_and_increase_quota(source_domain_id,source_project_id, "zones")
    # update recordset limits for this project if needed
    check_and_increase_quota(
      source_domain_id,
      source_project_id, 
      "recordsets",
      2,
    )

    # update zone limits for destination project if needed
    if target_project_id.present? && (target_project_id != source_project_id)
      # first, get the latests state of the limes data for target project
      update_limes_data(target_domain_id, target_project_id)  
      # check and increase zone quota for destination project
      check_and_increase_quota(target_domain_id, target_project_id, "zones")
    end
  end

  def transfer_zone_if_needed(zone, source_project_id, target_project_id)
    if target_project_id != source_project_id
      # zone should be transferred from target project to this project
      # try to find existing zone transfer request
      zone_transfer_request = services.dns_service.zone_transfer_requests(
        status: 'ACTIVE'
      ).select do |zone_transfer_request|
        zone_transfer_request.target_project_id == source_project_id &&
          zone_transfer_request.zone_id == zone.id
      end.first

      # create a new zone transfer request if not exists
      zone_transfer_request ||= services.dns_service.new_zone_transfer_request(
        zone.id, target_project_id: source_project_id, source_project_id: zone.project_id
      )
      zone_transfer_request.description = "create new zone via elektra"

      zone_transfer_request.save && zone_transfer_request.accept(source_project_id)
      # catch errors for transfer zone request
      return zone_transfer_request.errors
    end
  end

  def check_and_increase_quota(domain_id, project_id, resource, increase = 1)
    # get dns quota for resource and target project
    dns_resource =
      cloud_admin
        .resource_management
        .find_project(domain_id, project_id, service: "dns", resource: resource)
        .resources
        .first or raise ActiveRecord::RecordNotFound

    # NOTE: dns_resource.usable_quota is quota + burst
    if dns_resource.quota == 0 || dns_resource.quota <= dns_resource.usage
      if dns_resource.quota < dns_resource.usage
        puts "INFO: for project #{project_id} in domain #{domain_id} the usable quota is smaller than usage! Set quota for resource #{resource} to #{dns_resource.usage + increase}"
        # special case if usable quota is smaller than usage than adjust new quota to usage plus increase value
        dns_resource.quota = dns_resource.usage + increase
      else
        puts "INFO: increase quota for project #{project_id} in domain #{domain_id} for resource #{resource} by #{increase}"
        # standard increase quota plus increase value
        dns_resource.quota += increase
      end
      unless dns_resource.save
        # catch error for automatic quota adjustment
        dns_resource.errors.each { |k, m| @zone_request.errors.add(k, m) }
      else
        puts "INFO: wait 3s to be sure that limes could set the quota correctly"
        sleep 3
      end
    end
  end

  def update_limes_data(domain_id, project_id)
    # get last scraped time
    current_timestamp = Time.now.to_i
      # update limes data synchronously
      cloud_admin.resource_management.sync_project_asynchronously(
        domain_id,
        project_id,
      )
      
    scraped_at = current_timestamp
    retry_count = 1
    while scraped_at.to_i <= current_timestamp && retry_count <= 10
      puts "INFO: update limes data for project #{project_id} in domain #{domain_id}, wait 2s to check that update is done"
      sleep 3
      scraped_at =
        begin
          cloud_admin
            .resource_management
            .find_project(domain_id, project_id, service: "dns", resource: "zones")
            .services
            .first
            .scraped_at
        rescue StandardError
          0
        end
      puts "INFO: check limes update. retry_count: #{retry_count}; scraped_at_old: #{current_timestamp}; scraped_at_new: #{scraped_at.to_i}"
      retry_count += 1
    end
  end

  def get_zone_resource
    cloud_admin
      .resource_management
      .find_project(@scoped_domain_id, @scoped_project_id, service: "dns", resource: "zones",)
      .resources
      .first or raise ActiveRecord::RecordNotFound
  end

  def get_recordset_resource
    @recordset_resource =
      cloud_admin
        .resource_management
        .find_project(@scoped_domain_id, @scoped_project_id, service: "dns", resource: "recordsets")
        .resources
        .first or raise ActiveRecord::RecordNotFound
  end
end

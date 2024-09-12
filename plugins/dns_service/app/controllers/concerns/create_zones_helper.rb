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
end

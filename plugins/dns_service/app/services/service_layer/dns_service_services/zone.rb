# frozen_string_literal: true

module ServiceLayer
  module DnsServiceServices
    # This module implements Openstack Designate Pool API
    module Zone
      def zone_map
        @zone_map ||= class_map_proc(DnsService::Zone)
      end

      def shared_zone_map
        @shared_zone_map ||= class_map_proc(DnsService::SharedZone)
      end

      def zones(filter = {})
        project_id = ""
        header_options = {}
        if filter[:project_id]
          project_id = filter.delete(:project_id)
          header_options = {"x-auth-sudo-project-id": project_id}
        end
        if filter[:all_projects]
          filter.delete(:all_projects)
          header_options = {"x-auth-all-projects": "true"}
        end
        response = elektron_dns.get('zones', filter, headers: header_options)
        {
          items: response.map_to('body.zones', &zone_map),
          total: response.body.fetch('metadata', {}).fetch('total_count', nil)
        }
      end

      def shared_zones(filter = {})
        project_id = ""
        header_options = {}
        if filter[:project_id]
          project_id = filter.delete(:project_id)
          header_options = {"x-auth-sudo-project-id": project_id}
        end
        response = elektron_dns.get('zones/share').map_to('body.shared_zones',&shared_zone_map)
      end

      def new_zone(attributes = {})
        zone_map.call(attributes)
      end

      def new_shared_zone(attributes = {})
        shared_zone_map.call(attributes)
      end

      def find_zone!(id, filter = {})
        elektron_dns.get("zones/#{id}", filter).map_to('body', &zone_map)
      end

      def find_zone(id, filter = {})
        find_zone!(id, filter)
      rescue Elektron::Errors::ApiResponse => _e
        nil
      end

      ################### MODEL INTERFACE ####################
      def create_zone(attributes = {})

        project_id = ""
        header_options = {}
        # if project_id is given create the zone for this project
        # this is the case if the domain a subdomain of existing domain in the project
        if attributes[:project_id]
          project_id = attributes.delete(:project_id)
          header_options = {"x-auth-sudo-project-id": project_id}
        end

        elektron_dns.post('zones',  headers: header_options) do
          attributes
        end.body
      end

      def update_zone(id, attributes = {})
        filter = {}
        filter[:all_projects] = attributes.delete(:all_projects)
        filter[:project_id] = attributes.delete(:project_id)

        elektron_dns.patch("zones/#{id}", filter) do
          attributes
        end.body
      end

      def delete_zone(id, filter = {})
        elektron_dns.delete("zones/#{id}", filter)
      end

      def create_shared_zone(attributes = {})
        elektron_dns.post('zones/share') do
          attributes
        end.body
      end

      def delete_shared_zone(id)
        elektron_dns.delete("zones/share/#{id}")
      end

    end
  end
end

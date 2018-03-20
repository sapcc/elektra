# frozen_string_literal: true

module Lookup
  # Collect project information
  class ReverseLookupController < DashboardController
    def index; end

    def search
      res = {}

      search_value = params[:searchValue]

      if search_value.blank?
        render json: res
        return
      end

      # decide if IP or DNS
      if (IPAddr.new(search_value) rescue false)
        res[:searchValue] = search_value

        # floating IPs
        floating_ip = cloud_admin.networking.floating_ips(floating_ip_address: search_value).first
        if floating_ip.blank?
          render json: {}
          return
        end

        # project ID
        project_id = floating_ip.tenant_id
        res[:id] = project_id

        # project name
        identity_project = cloud_admin.identity.find_project(
          project_id, parents_as_ids: true
        )
        res[:name] = identity_project.name

        # ****
        parents = identity_project.parents
        puts "*****"
        puts parents
        puts testDeep(parents)
        puts "*****"
        # ****

        # parents
        parents = flatten_nested_hash(identity_project.parents)
        project_parent_list = []
        # add found project
        project_parent_list.unshift({name: identity_project.name, id: project_id})
        # add parents
        parents.each do |parent|
          parent_project = cloud_admin.identity.find_project(parent)
          project_parent_list.unshift({name: parent_project.name, id: parent_project.id})
        end

        res[:parents] = project_parent_list
      else
        # head 500
      end
      render json: res
    end

    def testDeep(hash)
      unless hash.blank?
        hash.flat_map do |k, v|
          project = cloud_admin.identity.find_project(k)
          { id: project.id, name: project.name, childNodes: testDeep(v) }
        end
      else
        {}
      end
    end

    def flatten_nested_hash(hash)
      unless hash.blank?
        hash.flat_map { |k, v| [k, *flatten_nested_hash(v)] }
      else
        []
      end
    end
  end
end

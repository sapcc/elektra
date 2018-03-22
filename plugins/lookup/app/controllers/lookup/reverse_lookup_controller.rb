# frozen_string_literal: true

module Lookup
  # Collect project information
  class ReverseLookupController < DashboardController
    def index; end

    def domain
      domain = cloud_admin.identity.find_domain(params[:reverseLookupDomainId])
      render json: { id: domain.id, name: domain.name }
    end

    def parents
      project_id = params[:reverseLookupProjectId]

      identity_project = cloud_admin.identity.find_project(
        project_id, parents_as_ids: true
      )

      parents = flatten_nested_hash(identity_project.parents)
      project_parent_list = []
      # add found project
      project_parent_list.unshift(name: identity_project.name, id: project_id)
      # add parents
      parents.each do |parent|
        parent_project = cloud_admin.identity.find_project(parent)
        project_parent_list.unshift(name: parent_project.name, id: parent_project.id)
      end

      render json: project_parent_list
    end

    def users
    end

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

        # project id
        project_id = floating_ip.tenant_id
        res[:id] = project_id

        # project name
        identity_project = cloud_admin.identity.find_project(
          project_id, parents_as_ids: true
        )
        res[:name] = identity_project.name

        # domain id
        res[:domainId] = identity_project.domain_id
      else
        # head 500
      end
      render json: res
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

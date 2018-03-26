# frozen_string_literal: true

module Lookup
  # Collect project information
  class ReverseLookupController < DashboardController

    module SEARCH_BY
      IP = 'ip'
      DNS = 'dns'
    end

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
      project_id = params[:reverseLookupProjectId]
      filter_by = params[:filterby]
      # role object
      role = nil
      if filter_by == SEARCH_BY::IP
        role = cloud_admin.identity.find_role_by_name('network_admin')
      elsif filter_by == SEARCH_BY::DNS
        role = cloud_admin.identity.find_role_by_name('dns_admin')
      end
      # role assigments
      assigments = cloud_admin.identity.role_assignments(
        'scope.project.id' => project_id,
        'role.id' => role.id,
        include_names: true
      )
      # get users
      ra_users = []
      assigments.select{|ra| !ra.user.blank?}.each_with_object([]) do |ra, users|
        user_profile = UserProfile.search_by_name(ra.user[:name]).first
        ra_users << "#{ra.user[:name]}#{(' (' + user_profile["full_name"] + ')') unless user_profile.blank?}"
      end

      render json: {users: ra_users}
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
        res[:searchBy] = SEARCH_BY::IP

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

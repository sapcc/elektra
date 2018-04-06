# frozen_string_literal: true

module Lookup
  # Collect project information
  class ReverseLookupController < DashboardController
    before_action :role_assigments, only: [:users, :groups]

    module SearchBy
      IP = 'ip'
      DNS = 'dns'
    end

    def index; end

    def domain
      identity_project = cloud_admin.identity.find_project(params[:reverseLookupProjectId])
      domain = cloud_admin.identity.find_domain(identity_project.domain_id)
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
      # get users
      ra_users = []
      @assigments.reject{ |ra| ra.user.blank? }.each_with_object([]) do |ra, _|
        user_profile = UserProfile.search_by_name(ra.user[:name]).first
        user = { name: ra.user[:name], id: ra.user[:id] }
        user[:fullName] = user_profile['full_name'] unless user_profile.blank?
        ra_users << user
      end

      render json: ra_users
    end

    def groups
      groups = @assigments.reject{ |ra| ra.group.blank? }.map do |ra|
        { id: ra.group[:id], name: ra.group[:name] }
      end

      render json: groups
    end

    def group_members
      group_id = params[:reverseLookupGrouptId]
      members_raw = cloud_admin.identity.group_members(group_id)

      members = members_raw.map do |item|
        { name: item.name, id: item.id, fullName: item.description }
      end

      render json: members
    end

    def search
      res = {}
      search_value = params[:searchValue]
      res[:searchValue] = search_value

      if search_value.blank?
        render json: res, status: 404
        return
      end

      # decide if IP or DNS
      if (IPAddr.new(search_value) rescue false)
        res[:searchBy] = SearchBy::IP

        # floating IPs
        floating_ip = cloud_admin.networking.floating_ips(floating_ip_address: search_value).first
        if floating_ip.blank?
          render json: res, status: 404
          return
        end

        # project id
        project_id = floating_ip.tenant_id
        res[:id] = project_id

        # project name
        identity_project = cloud_admin.identity.find_project(project_id)
        res[:name] = identity_project.name
      else
        res[:searchBy] = SearchBy::DNS

        dns_record = cloud_admin.dns_service.zones(all_projects: true, name: search_value).fetch(:items, []).first
        if dns_record.blank?
          render json: res, status: 404
          return
        end

        res[:id] = dns_record.project_id
        res[:name] = dns_record.name
      end

      render json: res
    end

    def role_assigments
      project_id = params[:reverseLookupProjectId]
      filter_by = params[:filterby]
      # role object
      role = nil
      if filter_by == SearchBy::IP
        role = cloud_admin.identity.find_role_by_name('network_admin')
      elsif filter_by == SearchBy::DNS
        role = cloud_admin.identity.find_role_by_name('dns_admin')
      end
      # role assigments
      @assigments = cloud_admin.identity.role_assignments(
        'scope.project.id' => project_id,
        'role.id' => role.id,
        include_names: true
      )
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

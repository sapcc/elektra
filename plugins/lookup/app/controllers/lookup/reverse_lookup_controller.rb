# frozen_string_literal: true

module Lookup
  # Collect project information
  class ReverseLookupController < DashboardController

    authorization_context 'lookup'
    authorization_required

    before_action :role_assigments, only: [:users, :groups]

    SEARCHBY = { ip: 'ip', dns: 'dns' }.freeze
    SEARCHBY.values.each(&:freeze) # change because of warning{ |v| v.freeze }

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

    def object_info
      search_by = params[:searchBy]
      obj_id = params[:reverseLookupObjectId]
      res = {searchBy: search_by, searchObjectId: obj_id}

      if search_by == SEARCHBY[:ip]
        floating_ip = cloud_admin.networking.find_floating_ip(obj_id)
        if floating_ip.blank?
          render json: res, status: 404
          return
        end
        res[:detailsTitle] = 'Port information'
        res[:details] = cloud_admin.networking.find_port(floating_ip.port_id)
      elsif search_by == SEARCHBY[:dns]
        recordsets = cloud_admin.dns_service.recordsets(obj_id, all_projects: true).fetch(:items, [])
        if recordsets.blank?
          render json: res, status: 404
          return
        end
        res[:detailsTitle] = 'Recordsets information'
        res[:details] = recordsets
      end
      render json: res
    end

    def project
      project_id = params[:reverseLookupProjectId]
      res = { searchProjectId: project_id }

      identity_project = cloud_admin.identity.find_project(project_id)
      res[:id] = identity_project.id
      res[:name] = identity_project.name

      render json: res
    end

    def search
      res = {}
      search_value = params[:searchValue]
      res[:searchValue] = search_value
      res[:searchTypes] = SEARCHBY

      if search_value.blank?
        render json: res, status: 404
        return
      end

      # decide if IP or DNS
      if (IPAddr.new(search_value) rescue false)
        res[:searchBy] = SEARCHBY[:ip]

        # floating IPs
        floating_ip = cloud_admin.networking.floating_ips(floating_ip_address: search_value).first
        if floating_ip.blank?
          render json: res, status: 404
          return
        end

        # object id
        res[:id] = floating_ip.id
        res[:name] = floating_ip.floating_ip_address

        # project id
        res[:projectId] = floating_ip.tenant_id
      else
        res[:searchBy] = SEARCHBY[:dns]

        # check if the dns has a point at the end
        unless search_value.end_with? '.'
          search_value = search_value + '.'
        end

        dns_record = cloud_admin.dns_service.zones(all_projects: true, name: search_value).fetch(:items, []).first
        if dns_record.blank?
          render json: res, status: 404
          return
        end

        # object id, name
        res[:id] = dns_record.id
        res[:name] = dns_record.name

        # project id
        res[:projectId] = dns_record.project_id
      end

      render json: res
    end

    def role_assigments
      project_id = params[:reverseLookupProjectId]

      # role object
      role = cloud_admin.identity.find_role_by_name('admin')

      # role assigments
      @assigments = cloud_admin.identity.role_assignments(
        'scope.project.id' => project_id,
        'role.id' => role.id,
        include_names: true
      )
    end

    def flatten_nested_hash(hash)
      if hash.blank?
        []
      else
        hash.flat_map { |k, v| [k, *flatten_nested_hash(v)] }
      end
    end
  end
end

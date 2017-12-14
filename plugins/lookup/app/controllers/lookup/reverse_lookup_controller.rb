module Lookup
  class ReverseLookupController < Lookup::ApplicationController
    authorization_context 'lookup'
    authorization_required

    def index
      @sources = {floating_ip: "Floating IP", dns: "DNS"}

      if params[:source]
        # lookup by source
        @floating_ip = cloud_admin.networking.floating_ips(floating_ip_address: params[:value]).first
        # @floating_ip = cloud_admin.networking.find_floating_ip('04c35d11-d11f-4127-845b-6e3b717b65a8')

        if @floating_ip
          project_id = @floating_ip.tenant_id
        end

        identity_project = cloud_admin.identity.find_project(
          project_id, parents_as_ids: true
        )


        parents = flatten_nested_hash(identity_project.parents)

        project_parent_list = []

        parents.each do |parent|
          parent_project = cloud_admin.identity.find_project(parent)
          project_parent_list.unshift({name: parent_project.name, id: parent_project.id})
        end

        @project = {name: identity_project.name, id: identity_project.id, parents: project_parent_list}

        roles = cloud_admin.identity.roles.delete_if{|role| !role.name[/^network_admin$|^dns_admin$/]}
        # (domain_id: identity_project.domain_id, name: "network_admin")

        # EFFECTIVE???!??
        @role_assignments = roles.each_with_object([]) do |role, role_assignments|
          role_assignment_data = {name: role.name}
          role_assignment_data[:assignments] = cloud_admin.identity.role_assignments(
            'scope.project.id' => project_id,
            'role.id' => role.id,
            include_names: true
          )
          role_assignments << role_assignment_data
        end

        # Users
        @users = @role_assignments.each_with_object({}) do |ra_data, users|
          ra_users = []
          ra_data[:assignments].select{|ra| !ra.user.blank?}.each_with_object([]) do |ra, users|
            user_profile = UserProfile.search_by_name(ra.user[:name]).first
            ra_users << "#{ra.user[:name]}#{(' (' + user_profile["full_name"] + ')') unless user_profile.blank?}"
          end
          users[ra_data[:name]] = ra_users
        end

        # Groups
        groups = @role_assignments.first[:assignments].select{|ra| !ra.group.blank?}.map{ |ra| ra.group}

        @groups_users = groups.each_with_object([]) do |g, groups_users|
          groups_users << {name: g[:name], users: cloud_admin.identity.group_members(g[:id]).map{ |u| "#{u.name} (#{u.description})"}}
        end

        # puts "------------- #{identity_project}"
        # puts "++++++++++++ #{project_parent_list}"
        # puts " ----------- #{@project}"
        # puts "____________ #{roles}"
        # puts " ++++++++++ #{@role_assignments.select{|ra| !ra.user.blank?}.map{|ra| ra.user}}"

      end
    end

    def flatten_nested_hash(hash)
      unless hash.blank?
        hash.flat_map{|k, v| [k, *flatten_nested_hash(v)]}
      else
        []
      end
    end


  end
end

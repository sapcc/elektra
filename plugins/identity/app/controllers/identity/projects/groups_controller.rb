module Identity
  module Projects
    class GroupsController < ::DashboardController
      before_filter :load_roles, except: [:new]

      def new
        enforce_permissions("identity:project_group_create",{domain_id: @scoped_domain_id})
        @groups = service_user.groups(domain_id: @scoped_domain_id)
      end

      def create
        enforce_permissions("identity:project_group_create",{domain_id: @scoped_domain_id})

        @group = nil if params[:group_name].blank?
        @group = service_user.groups(domain_id: @scoped_domain_id,name:params[:group_name]).first rescue nil unless @group
        @group = service_user.find_group(params[:group_name]) rescue nil unless @group

        load_role_assignments
        @groups = service_user.groups(domain_id: @scoped_domain_id)
        @group = @groups.select{|group| group.name==params[:group_name] || group.id==params[:group_name]}.first rescue nil

        if @group.nil? or @group.id.nil?
          @error = "Group not found."
          render action: :new
        elsif @group_roles[@group.id]
          @error = "Group is already assigned to this project."
          render action: :new
        elsif @group.domain_id!=@scoped_domain_id
          @error = "Group is not a member of this domain."
          render action: :new
        else
          render action: :create
        end
      end

      def members
        @members = begin 
          service_user.group_members(params[:group_id])
        rescue 
          services.identity.group_members(params[:group_id])
        end
      end

      def index
        enforce_permissions("identity:project_group_list",{domain_id: @scoped_domain_id})
        load_role_assignments
      end

      def update
        enforce_permissions("identity:project_group_update",{domain_id: @scoped_domain_id})
        load_role_assignments

        available_role_ids = @roles.collect{|r| r.id}

        # update changed roles
        updated_roles_group_ids = []
        if params[:role_assignments]
          params[:role_assignments].each do |group_id,new_group_role_ids|
            updated_roles_group_ids << group_id
            old_group_role_ids = (@group_roles[group_id] || {roles: []})[:roles].collect{|role| role[:id]}

            role_ids_to_add = new_group_role_ids-old_group_role_ids
            role_ids_to_remove = old_group_role_ids-new_group_role_ids

            role_ids_to_add.each do |role_id|
              if available_role_ids.include?(role_id)
                service_user.grant_project_group_role(@scoped_project_id, group_id, role_id) rescue nil
              end
            end
            role_ids_to_remove.each do |role_id|
              if available_role_ids.include?(role_id)
                service_user.revoke_project_group_role(@scoped_project_id, group_id, role_id) rescue nil
              end
            end
          end
        end

        # remove roles
        (@group_roles.keys-updated_roles_group_ids).each do |group_id|
          role_ids_to_remove = (@group_roles[group_id] || {})[:roles].collect{|role| role[:id]}
          role_ids_to_remove.each do |role_id|
            if available_role_ids.include?(role_id)
              service_user.revoke_project_group_role(@scoped_project_id, group_id, role_id) rescue nil
            end
          end
        end

        audit_logger.info(current_user, "has updated group role assignments for project #{@scoped_project_name} (#{@scoped_project_id})")

        redirect_to projects_groups_path
      end

      protected


      def load_roles
        ignore_roles = ['service','network_admin','cloud_network_admin','swiftreseller']
        @roles = (service_user.roles rescue []).delete_if{|role| ignore_roles.include?(role.name)}
      end

      def load_role_assignments
        #@role_assignments ||= services.identity.role_assignments("scope.project.id"=>@scoped_project_id)
        @role_assignments ||= service_user.role_assignments("scope.project.id"=>@scoped_project_id, include_names: true, include_subtree: true)
        @group_roles ||= @role_assignments.inject({}) do |hash,ra|
          group_id = (ra.group || {}).fetch("id",nil)
          project_id = (ra.scope || {}).fetch("project",{}).fetch("id",nil)
          # ignore user role assignments
          if group_id and project_id==@scoped_project_id
            hash[group_id] ||= {role_ids: [], roles:[], name: ra.group.fetch("name",'unknown')}
            hash[group_id][:roles] << { id: ra.role["id"], name: ra.role["name"] }
          end
          hash
        end
        @group_roles.sort_by { |group_id, age| group_id }
      end
    end
  end
end

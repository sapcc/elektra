module Identity
  module Projects
    module CloudAdmin
      class ProjectMembersController < ::DashboardController
        before_filter :load_project
        before_filter :load_roles

        def index
          enforce_permissions("identity:project_member_list",{})
          load_role_assignments(@project.id) if @project
        end

        def new
          enforce_permissions("identity:project_member_create",{})
        end

        def create
          enforce_permissions("identity:project_member_create",{})
          @user = params[:user_name].blank? ? nil : begin
            services_ng.identity.users(domain_id: @domain.id,name:params[:user_name]).first
          rescue
            services_ng.identity.find_user(params[:user_name]) rescue nil
          end

          load_role_assignments(@project.id)
          if @user.nil? or @user.id.nil?
            @error = "User not found."
            render action: :new
          elsif @user_roles[@user.id]
            @error = "User is already a member of this project."
            render action: :new
          elsif @user.domain_id!=@domain.id
            @error = "User is not a member of this domain."
            render action: :new
          else
            render action: :create
          end
        end

        def update
          enforce_permissions("identity:project_member_update",{})
          load_role_assignments(@project.id)

          available_role_ids = @roles.collect{|r| r.id}

          # update changed roles
          updated_roles_user_ids = []
          if params[:role_assignments]
            params[:role_assignments].each do |user_id,new_user_role_ids|
              updated_roles_user_ids << user_id
              old_user_role_ids = (@user_roles[user_id] || {roles: []})[:roles].collect{|role| role[:id]}

              role_ids_to_add = new_user_role_ids-old_user_role_ids
              role_ids_to_remove = old_user_role_ids-new_user_role_ids

              role_ids_to_add.each do |role_id|
                if available_role_ids.include?(role_id)
                  services_ng.identity.grant_project_user_role(@project.id, user_id, role_id) #rescue nil
                end
              end

              role_ids_to_remove.each do |role_id|
                if available_role_ids.include?(role_id)
                  services_ng.identity.revoke_project_user_role(@project.id, user_id, role_id) # rescue nil
                end
              end
            end
          end

          # remove roles
          (@user_roles.keys-updated_roles_user_ids).each do |user_id|
            role_ids_to_remove = (@user_roles[user_id] || {})[:roles].collect{|role| role[:id]}
            role_ids_to_remove.each do |role_id|
              if available_role_ids.include?(role_id)
                services_ng.identity.revoke_project_user_role(@project.id, user_id, role_id) #rescue nil
              end
            end
          end

          audit_logger.info("Cloud Admin #{current_user.name} (#{current_user.id}) has updated user role assignments for project #{@project.name} (#{@project.id})")
          redirect_to projects_cloud_admin_project_members_path(pid:@project.id)
        end

        protected

        def load_project
          project_id = params[:pid]

          @project = services_ng.identity.find_project(project_id.strip) rescue nil if project_id
          @domain = services_ng.identity.find_domain(@project.domain_id) if @project
        end

        # FIXME: duplicated in ProjectGroupsController
        def load_roles
          @roles = services_ng.identity.roles.sort_by(&:name)
        end

        def load_role_assignments(project_id)
          #@role_assignments ||= services_ng.identity.role_assignments("scope.project.id"=>@scoped_project_id)
          # we need to add include_subtree option to have permissions. But this causes that other projects then current are included in this list.
          @role_assignments ||= services_ng.identity.role_assignments("scope.project.id"=>project_id, include_names: true)

          @user_roles ||= @role_assignments.inject({}) do |hash,ra|
            user_id = (ra.user || {}).fetch("id",nil)
            role_project_id = (ra.scope || {}).fetch("project",{}).fetch("id",nil)
            # ignore group role assignments and other projects
            if user_id and role_project_id==project_id
              hash[user_id] ||= {role_ids: [], roles:[], name: ra.user.fetch("name",'unknown')}
              hash[user_id][:roles] << { id: ra.role["id"], name: ra.role["name"] }
            end
            hash
          end
          @user_roles.sort_by { |user_id, age| user_id }
        end

      end
    end
  end
end

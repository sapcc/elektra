module Identity
  module Projects
    module CloudAdmin
      class ProjectGroupsController < ::DashboardController
        before_filter :load_project
        before_filter :load_roles
        
        def index
          enforce_permissions("identity:project_group_list",{})
          load_role_assignments(@project.id) if @project
        end
        
        def new
          enforce_permissions("identity:project_group_create",{})
          @groups = services.identity.groups(domain_id: @domain.id)
        end
        
        def create
          enforce_permissions("identity:project_group_create",{})

          @group = nil if params[:group_name].blank?
          @group = services.identity.groups(domain_id: @domain.id,name:params[:group_name]).first rescue nil unless @group
          @group = services.identity.find_group(params[:group_name]) rescue nil unless @group

          load_role_assignments(@project.id)
          @groups = services.identity.groups(domain_id: @domain.id)
        
          p ">>>>>>>>>>>>>>>>>>>>>>>>>>>>"
          p @group
          if @group.nil? or @group.id.nil?
            @error = "Group not found."
            render action: :new
          elsif @group_roles[@group.id]
            @error = "Group is already assigned to this project."
            render action: :new
          elsif @group.domain_id!=@domain.id
            @error = "Group is not a member of this domain."
            render action: :new
          else
            render action: :create
          end 
        end
        
        def update
          enforce_permissions("identity:project_group_update",{})
          load_role_assignments(@project.id)

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
                  services.identity.grant_project_group_role(@project.id, group_id, role_id) #rescue nil
                end
              end
              role_ids_to_remove.each do |role_id| 
                if available_role_ids.include?(role_id) 
                  services.identity.revoke_project_group_role(@project.id, group_id, role_id) #rescue nil
                end
              end
            end
          end
        
          # remove roles
          (@group_roles.keys-updated_roles_group_ids).each do |group_id|
            role_ids_to_remove = (@group_roles[group_id] || {})[:roles].collect{|role| role[:id]}
            role_ids_to_remove.each do |role_id| 
              if available_role_ids.include?(role_id) 
                services.identity.revoke_project_group_role(@project.id, group_id, role_id) #rescue nil
              end
            end
          end
        
          audit_logger.info("Cloud admin #{current_user.name} (#{current_user.id}) has updated group role assignments for project #{@project.name} (#{@project.id})")
        
          redirect_to projects_cloud_admin_project_groups_path(pid:@project.id)
        end
        
        protected 
        
        def load_project
          project_id = params[:pid]
          
          @project = services.identity.find_project(project_id.strip) rescue nil if project_id
          @domain = services.identity.find_domain(@project.domain_id) if @project
        end

        def load_roles
          @roles = services.identity.roles rescue []
        end
      
        def load_role_assignments(project_id)
          @role_assignments ||= services.identity.role_assignments("scope.project.id"=>project_id, include_names: true, include_subtree: true)
          @group_roles ||= @role_assignments.inject({}) do |hash,ra| 
            group_id = (ra.group || {}).fetch("id",nil)
            role_project_id = (ra.scope || {}).fetch("project",{}).fetch("id",nil)
            # ignore user role assignments
            if group_id and role_project_id==project_id
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
end
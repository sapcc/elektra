module Identity
  module Projects
    class GroupsController < ::DashboardController  
      before_filter :load_roles, except: [:new]
      
      def new
      end
      
      def create
        @group = params[:group_name].blank? ? nil : begin 
          service_user.groups(domain_id: @scoped_domain_id,name:params[:group_name]).first 
        rescue
          service_user.find_group(params[:group_name]) rescue nil
        end
        
        load_role_assignments
        
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
      
      def index
        load_role_assignments
      end
      
      def update
        load_role_assignments

        # update changed roles
        updated_roles_group_ids = []
        if params[:role_assignments]
          params[:role_assignments].each do |group_id,new_group_role_ids|
            updated_roles_group_ids << group_id
            old_group_role_ids = (@group_roles[group_id] || {roles: []})[:roles].collect{|role| role[:id]}
           
            role_ids_to_add = new_group_role_ids-old_group_role_ids
            role_ids_to_remove = old_group_role_ids-new_group_role_ids

            role_ids_to_add.each{|role_id| service_user.grant_project_group_role(@scoped_project_id, group_id, role_id)}
            role_ids_to_remove.each{|role_id| service_user.revoke_project_group_role(@scoped_project_id, group_id, role_id)}
          end
        end
        
        # remove roles
        (@group_roles.keys-updated_roles_group_ids).each do |group_id|
          role_ids_to_remove = (@group_roles[group_id] || {})[:roles].collect{|role| role[:id]}
          role_ids_to_remove.each{|role_id| service_user.revoke_project_group_role(@scoped_project_id, group_id, role_id)}
        end
        
        redirect_to projects_groups_path
      end

      protected 

      
      def load_roles
        @roles = service_user.roles rescue []
      end
      
      def load_role_assignments
        #@role_assignments ||= services.identity.role_assignments("scope.project.id"=>@scoped_project_id)
        @role_assignments ||= service_user.role_assignments("scope.project.id"=>@scoped_project_id, include_names: true, include_subtree: true)
        @group_roles ||= @role_assignments.inject({}) do |hash,ra| 
          group_id = (ra.group || {}).fetch("id",nil)
          # ignore user role assignments
          if group_id
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

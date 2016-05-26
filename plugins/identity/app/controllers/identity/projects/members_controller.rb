module Identity
  module Projects
    class MembersController < ::DashboardController  
      before_filter :load_project, :load_roles, except: [:new]
      
      def new
      end
      
      def create
        @user = params[:user_name].blank? ? nil : begin 
          service_user.users(domain_id: @scoped_domain_id,name:params[:user_name]).first 
        rescue
          service_user.find_user(params[:user_name]) rescue nil
        end
        
        load_role_assignments
        
        if @user.nil? or @user.id.nil?
          @error = "User not found."
          render action: :new
        elsif @user_roles[@user.id]
          @error = "User is already a member of this project."
          render action: :new
        elsif @user.domain_id!=@scoped_domain_id
          @error = "User is not a member of this domain."
          render action: :new
        else
          render action: :create
        end  
      end
      
      def index
        load_role_assignments
      end
    
      def update
        # save new role assignments
        params[:role_assignments].each do |user_id,roles|
          roles.each do |role_id, value|
            if value=="1"
              service_user.grant_project_user_role(@scoped_project_id, user_id, role_id) rescue nil
            else
              service_user.revoke_project_user_role(@scoped_project_id, user_id, role_id) rescue nil
            end
          end
        end
        
        redirect_to projects_members_path
      end
      
      protected 
      
      def load_project
        @project = services.identity.find_project(@scoped_project_id)
      end
      
      def load_roles
        # ignore_roles = ['service', 'monasca-agent',  'monasca-user',  'cloud_admin', 'domain_admin', 'project_admin']
        relevant_roles = ['admin','member']
        @roles = (service_user.roles rescue []).inject({}) do |available_roles, role|
          # available_roles[role.id]=role unless ignore_roles.include?(role.name)
          available_roles[role.id]=role if relevant_roles.include?(role.name)
          available_roles
        end
      end
      
      def load_role_assignments
        #@role_assignments ||= services.identity.role_assignments("scope.project.id"=>@scoped_project_id)
        @role_assignments ||= service_user.role_assignments("scope.project.id"=>@scoped_project_id,effective: true, include_names: true, include_subtree: true)
        @user_roles ||= @role_assignments.inject({}) do |hash,ra| 
          user_id = (ra.user || {}).fetch("id",nil)
          next unless user_id
          hash[user_id] ||= {role_ids: [], name: ra.user.fetch("name",'unknown')}
          hash[user_id][:role_ids] << ra.role.fetch("id",nil)
          hash
        end
      end
    end
  end
end

module Identity
  module Projects
    class MembersController < ::DashboardController  
      before_filter :load_project, :load_roles, except: [:new]
      
      def new
      end
      
      def create
        @user = begin 
          services.identity.users(name:params[:user_name]).first 
        rescue
          services.identity.find_user(params[:user_name]) rescue nil
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
              services.identity.grant_project_user_role(@scoped_project_id, user_id, role_id) rescue nil
            else
              services.identity.revoke_project_user_role(@scoped_project_id, user_id, role_id) rescue nil
            end
          end
        end
        
        load_role_assignments
        render action: :index
      end
      
      protected 
      
      def load_project
        @project = services.identity.find_project(@scoped_project_id)
      end
      
      def load_roles
        ignore_roles = ['service', 'monasca-agent',	'monasca-user',	'cloud_admin', 'domain_admin', 'project_admin']
        @roles = (Admin::IdentityService.roles rescue []).inject({}) do |available_roles, role| 
          available_roles[role.id]=role unless ignore_roles.include?(role.name)
          available_roles
        end
      end
      
      def load_role_assignments
        @role_assignments = services.identity.role_assignments("scope.project.id"=>@scoped_project_id)
        @user_roles = user_roles(@role_assignments)
      end
      
      def user_roles(role_assignments={})
        role_assignments.inject({}) do |assignments, ra|
          user = ra.user_id.nil? ? nil : Admin::IdentityService.find_user(ra.user_id)
          if user and user.id
            assignments[ra.user_id] ||= {}
            assignments[ra.user_id][:user] ||= Admin::IdentityService.find_user(ra.user_id)
            assignments[ra.user_id][:role_ids] ||= []
            assignments[ra.user_id][:role_ids] << ra.role_id
          end
          assignments
        end
      end
    end
  end
end

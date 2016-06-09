module Core
  module ServiceUser
    class Base
      @@service_user_mutex = Mutex.new

      # # delegate some methods to auth_users
      delegate :token, :token_expired?, :token_expires_at, :domain_id, :domain_name, :context, :id, :default_services_region, :available_services_regions, to: :@auth_user

      # Class methods    
      class << self
        def load(params={})
          scope_domain = params[:scope_domain]
          return nil if scope_domain.nil?

          # puts ">>>>>Rails.configuration.keystone_endpoint: #{Rails.configuration.keystone_endpoint}"
          # puts ">>>>>Rails.configuration.default_region: #{Rails.configuration.default_region}"
          # puts ">>>>>Rails.configuration.service_user_id: #{Rails.configuration.service_user_id}"
          # puts ">>>>>Rails.configuration.service_user_password: #{Rails.configuration.service_user_password}"
          # puts ">>>>>Rails.configuration.service_user_domain_name: #{Rails.configuration.service_user_domain_name}"
          # puts ">>>>>scope_domain: #{scope_domain}"

          @@service_user_mutex.synchronize do
            @service_users ||= {}

            service_user = @service_users[scope_domain]
            if service_user.nil?
              @service_users[scope_domain] = self.new(
                  params[:user_id],
                  params[:password],
                  params[:user_domain],
                  scope_domain
              )
            end
          end

          @service_users[scope_domain]
        end
      end

      def token
        @driver.auth_token
      end

      def initialize(user_id, password, user_domain_name, scope_domain)
        @user_id = user_id
        @password = password
        @user_domain_name = user_domain_name
        @scope_domain = scope_domain
        authenticate
      end

      def authenticate
        # @scope_domain is a freindly id. So it can be the name or id
        # That's why we try to load the service user by id and if it 
        # raises an error then we try again by name. 
        @auth_user = begin
          MonsoonOpenstackAuth.api_client.auth_user(
              @user_id,
              @password,
              domain_name: @user_domain_name,
              scoped_token: {domain: {id: @scope_domain}}
          )
        rescue
          begin
            MonsoonOpenstackAuth.api_client.auth_user(
                @user_id,
                @password,
                domain_name: @user_domain_name,
                scoped_token: {domain: {name: @scope_domain}}
            )
          rescue MonsoonOpenstackAuth::Authentication::MalformedToken => e
            nil
            # raise ::Core::ServiceUser::Errors::AuthenticationError.new("Could not authenticate service user. Please check permissions on #{@scope_domain} for service user #{@user_id}")
          end
        end

        if @auth_user.nil? or @auth_user.token.blank?
          raise ::Core::ServiceUser::Errors::AuthenticationError.new("Could not authenticate service user. Please check permissions on #{@scope_domain} for service user #{@user_id}")
        end
        
        # Unfortunately we can't use Fog directly. Fog tries to authenticate the user
        # by credentials and region using the service catalog. Our backends all uses other regions.
        # Therefore we use the auth gem to authenticate the user get the service catalog and then 
        # we initialize the fog object. 
        @driver = ::Core::ServiceUser::Driver.new({
          auth_url: ::Core.keystone_auth_endpoint,
          region: Core.locate_region(@auth_user),
          token: @auth_user.token,
          domain_id: @auth_user.domain_id
        })
      end

      # execute driver method. Catch 401 errors (token invalid -> expired or revoked)
      def driver_method(method_sym, map, *arguments)
        if map
          @driver.map_to(Core::ServiceLayer::Model).send(method_sym, *arguments)
        else
          @driver.send(method_sym, *arguments)
        end
      rescue Core::ServiceLayer::Errors::ApiError => e
        # reauthenticate
        authenticate
        # and try again 
        if map
          @driver.map_to(Core::ServiceLayer::Model).send(method_sym, *arguments)
        else
          @driver.send(method_sym, *arguments)
        end
      end

      def users(filter={})
        driver_method(:users, true, filter)
      end

      def find_user(user_id)
        driver_method(:get_user, true, user_id)
      end
      
      def groups(filter={})
        driver_method(:groups, true, filter)
      end
      
      def group_members(group_id,filter={})
        driver_method(:group_members, true, group_id,filter)
      end

      def find_group(group_id)
        driver_method(:get_group, true, group_id)
      end

      def find_domain(domain_id)
        driver_method(:get_domain, true, domain_id)
      end

      def roles(filter={})
        driver_method(:roles, true, filter)
      end

      def role_assignments(filter={})
        #filter["scope.domain.id"]=self.domain_id unless filter["scope.domain.id"]
        driver_method(:role_assignments, true, filter)
      end

      def user_projects user_id, filter={}
        driver_method(:user_projects, true, user_id, filter)
      end

      def find_role_by_name(name)
        roles.select { |r| r.name==name }.first
      end

      def find_project_by_name_or_id(name_or_id)
        project = driver_method(:get_project, true, name_or_id) rescue nil
        unless project
          project = driver_method(:projects, true, {domain_id: self.domain_id, name: name_or_id}).first rescue nil
        end
        project
      end

      # def find_project(id)
      #   driver_method(:get_project,true,id)
      # end

      def grant_user_domain_member_role(user_id, role_name)
        role = self.find_role_by_name(role_name)
        driver_method(:grant_domain_user_role, false, self.domain_id, user_id, role.id)
      end
      
      def grant_project_user_role(project_id, user_id, role_id)
        driver_method(:grant_project_user_role, false, project_id, user_id, role_id)
      end
      
      def revoke_project_user_role(project_id, user_id, role_id)
        driver_method(:revoke_project_user_role, false, project_id, user_id, role_id)
      end
      
      def grant_project_group_role(project_id, group_id, role_id)
        driver_method(:grant_project_group_role, false, project_id, group_id, role_id)
      end
      
      def revoke_project_group_role(project_id, group_id, role_id)
        driver_method(:revoke_project_group_role, false, project_id, group_id, role_id)
      end
            
      def update_project(id,params)
        driver_method(:update_project, true, id,params)
      end
      
      def delete_project(id)
        driver_method(:delete_project,false,id)
      end

      def add_user_to_group(user_id, group_name)
        groups = driver_method(:groups, true, {domain_id: self.domain_id, name: group_name}) rescue []
        group = groups.first
        driver_method(:add_user_to_group, false, user_id, group.id) rescue false
      end

      def remove_user_from_group(user_id, group_name)
        groups = driver_method(:groups, true, {domain_id: self.domain_id, name: group_name}) rescue []
        group = groups.first
        driver_method(:remove_user_from_group, false, user_id, group.id) rescue false
      end

      def group_user_check(user_id, group_name)
        groups = driver_method(:groups, true, {domain_id: self.domain_id, name: group_name}) rescue []
        group = groups.first
        driver_method(:group_user_check, false, user_id, group.id) rescue false
      end

      # A special case of list_scope_admins that returns a list of CC admins.
      def list_ccadmins
        unless @admin_domain_id
          domain_name = ENV.fetch('MONSOON_OPENSTACK_CLOUDADMIN_DOMAIN', 'ccadmin')
          @admin_domain_id = driver_method(:domains, true, {name: domain_name}).first.id
        end

        return list_scope_admins({domain_id: @admin_domain_id})
      end

      # Returns admins for the given scope (e.g. project_id: PROJECT_ID, domain_id: DOMAIN_ID)
      # This method looks recursively for project, parent_projects and domain admins until it finds at least one.
      # It should always return a non empty list (at least the domain admins).
      def list_scope_admins(scope={})
        role = self.find_role_by_name('admin') rescue nil
        list_scope_assigned_users(scope.merge(role: role))
      end

      def list_scope_assigned_users!(options={})
        list_scope_assigned_users(options.merge(raise_error: true))
      end

      # Returns assigned users for the given scope and role (e.g. project_id: PROJECT_ID, domain_id: DOMAIN_ID, role: ROLE)
      # This method looks recursively for assigned users of project, parent_projects and domain. 
      def list_scope_assigned_users(options={})
        admins = []
        project_id = options[:project_id]
        domain_id = options[:domain_id]
        role = options[:role]
        raise_error = options[:raise_error]

        # do nothing if role is nil
        return admins if role.nil?

        begin

          if project_id # project_id is presented
            # get role_assignments for this project_id
            role_assignments = self.role_assignments("scope.project.id" => project_id, "role.id" => role.id, effective: true, include_subtree: true) #rescue []
            # load users (not very performant but there is no other option to get users by ids)
            role_assignments.each do |r|
              unless r.user["id"] == self.id
                admin = self.find_user(r.user["id"]) rescue nil
                admins << admin if admin
              end
            end
            if admins.length==0 # no admins for this project_id found
              # load project
              project = self.find_project(project_id) rescue nil
              if project
                # try to get admins recursively by parent_id 
                admins = list_scope_assigned_users(project_id: project.parent_id, domain_id: project.domain_id, role: role)
              end
            end
          elsif domain_id # project_id is nil but domain_id is presented
            # get role_assignments for this domain_id
            role_assignments = self.role_assignments("scope.domain.id" => domain_id, "role.id" => role.id, effective: true) #rescue []
            # load users
            role_assignments.each do |r|
              unless r.user["id"] == self.id
                admin = self.find_user(r.user["id"]) rescue nil
                admins << admin if admin
              end
            end
          end
        rescue => e
          raise e if raise_error
        end

        return admins.delete_if { |a| a.id == nil } # delete crap
      end
    end
  end
end

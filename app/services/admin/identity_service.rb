module Admin
  class IdentityService
    @@service_cache_mutex = Mutex.new

    class << self
      def create_user_domain_role(current_user,role_name)
        return false if current_user.nil? or role_name.nil?
        member_role = admin_identity.find_role_by_name(role_name)
        admin_identity.grant_domain_user_role(current_user.user_domain_id,current_user.id,member_role.id)
      end
        
      def method_missing(method_sym, *arguments, &block)
        if admin_identity.respond_to?(method_sym)
          admin_identity.send(method_sym,*arguments, &block)
        else
          super
        end
      end

      # A special case of list_scope_admins that returns a list of cloud admins.
      # This logic is hardcoded for now since the concept of a cloud admin will only
      # be introduced formally in the next Keystone release (Mitaka).
      def list_cloud_admins
        unless @admin_domain_id
          domain_name = ENV.fetch('MONSOON_OPENSTACK_CLOUDADMIN_DOMAIN', 'monsooncc')
          @admin_domain_id = admin_identity.domains(name: domain_name).first.id
        end

        return list_scope_admins({ domain_id: @admin_domain_id })
      end

      # Returns admins for the given scope (e.g. project_id: PROJECT_ID, domain_id: DOMAIN_ID)
      # This method looks recursively for project, parent_projects and domain admins until it finds at least one. 
      # It should always return a non empty list (at least the domain admins).
      def list_scope_admins(scope={})
        role = admin_identity.find_role_by_name('admin') rescue nil
        list_scope_assigned_users(scope.merge(role: role))
      end
      
      # Returns assigned users for the given scope and role (e.g. project_id: PROJECT_ID, domain_id: DOMAIN_ID, role: ROLE)
      # This method looks recursively for assigned users of project, parent_projects and domain. 
      def list_scope_assigned_users(options={})
        admins      = []
        project_id  = options[:project_id]
        domain_id   = options[:domain_id]
        role        = options[:role]
        
        # do nothing if role is nil
        return admins if role.nil?
        
        if project_id # project_id is presented
          # get role_assignments for this project_id
          role_assignments = admin_identity.role_assignments("scope.project.id"=>project_id,"role.id"=>role.id) rescue []
          # load users (not very performant but there is no other option to get users by ids)
          role_assignments.collect{|r| admins << admin_identity.find_user(r.user_id)  }
          
          if admins.length==0 # no admins for this project_id found
            # load project
            project = admin_identity.find_project(project_id) rescue nil
            if project 
              # try to get admins recursively by parent_id 
              admins = list_scope_assigned_users(project_id: project.parent_id, domain_id: project.domain_id, role: role)
            end  
          end
        elsif domain_id # project_id is nil but domain_id is presented
          # get role_assignments for this domain_id
          role_assignments = admin_identity.role_assignments("scope.domain.id"=>domain_id,"role.id"=>role.id, effective: true) rescue []
          # load users
          role_assignments.collect{|r|  admins << admin_identity.find_user(r.user_id) }       
        end
        
        return admins.delete_if {|a| a.id == nil} # delete crap
      end


      def service_user_token
        # init cache
        @@service_cache_mutex.synchronize do
          @service_cache = @service_cache || {}
        end

        # get service user from cache
        @service_user = @service_cache.fetch(Thread.current[:domain], {}).fetch(:user, nil)
        @service_user_expires_at = @service_cache.fetch(Thread.current[:domain], {}).fetch(:expires, nil)
        unless (@service_user and @service_user_expires_at and @service_user_expires_at>Time.now)
          @service_user = begin
            MonsoonOpenstackAuth.api_client.auth_user(
              Rails.application.config.service_user_id,
              Rails.application.config.service_user_password,
              domain_name: Rails.application.config.service_user_domain_name,
              scoped_token: {domain: {name: Thread.current[:domain]}} # fog requires a domain scoped token -> scope: { domain: {name: DOMAIN} }
            )
          rescue
            MonsoonOpenstackAuth.api_client.auth_user(
              Rails.application.config.service_user_id,
              Rails.application.config.service_user_password,
              domain_name: Rails.application.config.service_user_domain_name,
              scoped_token: {domain: {id: Thread.current[:domain]}} # fog requires a domain scoped token -> scope: { domain: {name: DOMAIN} }
            )
          end

          if @service_user
            # remember the token
            @service_user_expires_at = @service_user.token_expires_at

            # save to cache
            @@service_cache_mutex.synchronize do
              @service_cache[Thread.current[:domain]] = {user: @service_user, expires: @service_user_expires_at}
            end
          end
        end

        @service_user.token rescue nil
      end



      # def service_user_token
      #   # create a new service user unless already created or if token is expired
      #   unless (@service_user and @service_user_expires_at and @service_user_expires_at>Time.now)
      #     @service_user = MonsoonOpenstackAuth.api_client.auth_user(
      #       Rails.application.config.service_user_id,
      #       Rails.application.config.service_user_password,
      #       domain_name: Rails.application.config.service_user_domain_name,
      #       scoped_token: true # fog requires a domain scoped token -> scope: { domain: {name: DOMAIN} }
      #     )
      #     # remember the token
      #     @service_user_expires_at = @service_user.token_expires_at if @service_user
      #   end
      #   @service_user.token rescue nil
      # end
      
      def admin_identity
        # create new admin_identity unless already created or token has changed
        unless (@admin_identity and @admin_identity.token==service_user_token)
          @admin_identity = Core::ServiceLayer::ServicesManager.service(:identity, {
            region: Rails.application.config.default_region,
            token: service_user_token
          })
        end
          
        @admin_identity
      end
    end
  end
end

module ServiceLayer

  class IdentityService < Core::ServiceLayer::Service

    attr_reader :region

    def driver
      @driver ||= Identity::Driver::Fog.new({
                                                auth_url: self.auth_url,
                                                region: self.region,
                                                token: self.token,
                                                domain_id: self.domain_id,
                                                project_id: self.project_id
                                            })
    rescue Excon::Errors::Unauthorized => e
      # p ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>ERROR"
      #
      # p e.response.data rescue nil
      #
      # error_body = JSON.parse(e.response.data[:body])
      # p error_body
      raise Identity::InvalidToken.new(e)
    end

    def available?(action_name_sym=nil)
      not current_user.service_url('identity', region: region).nil?
    end

    def has_projects?
      driver.auth_projects.count>0
    end

    ##################### DOMAINS #########################
    def find_domain id
      return nil if id.blank?
      driver.map_to(Identity::Domain).get_domain(id)
    end

    def new_domain(attributes={})
      Identity::Domain.new(@driver, attributes)
    end

    def auth_domains
      @domains ||= driver.auth_domains.collect { |attributes| Identity::Domain.new(@driver, attributes) }
    end

    def domains(filter={})
      driver.map_to(Identity::Domain).domains(filter)
    end

    ##################### PROJECTS #########################
    def new_project(attributes={})
      Identity::Project.new(@driver, attributes)
    end

    def find_project(id=nil, options=[])
      return nil if id.blank?
      driver.map_to(Identity::Project).get_project(id, options)
    end

    def projects_by_user_id(user_id)
      driver.map_to(Identity::Project).user_projects(user_id)
    end

    def auth_projects(domain_id=nil)
      # caching
      @auth_projects ||= driver.map_to(Identity::Project).auth_projects

      return @auth_projects if domain_id.nil?
      @auth_projects.select { |project| project.domain_id==domain_id }
    end

    def auth_projects_tree(projects: projects)
      Rails.cache.fetch("#{current_user.token}/auth_projects_tree", expires_in: 60.seconds) do
        auth_projects_tree_nocache(projects: projects)
      end
    end

    def auth_projects_tree_nocache(projects: projects)

      #projects = auth_projects(domain_id)
      root = Tree::TreeNode.new('domain', Hashie::Mash.new(current_user.context['domain']))

      projectid_map = {}
      parentid_map = {}

      if projects
        # Build node hash for quick access via id
        projects.each { |p| projectid_map[p.id] = Tree::TreeNode.new(p.id, p) }

        projects.each_with_index do |p, i|
          # check if node is root. true if parent is nil or if parent isn't part of project array
          isroot = false
          if p.parent_id == nil
            isroot = true
          elsif projectid_map[p.parent_id] == nil
            isroot = true
          end
          # add root nodes directly to root or build hash with parent/childs relation for quick access via parent id
          if isroot
            root << projectid_map[p.id]
          else
            parentid_map[projectid_map[p.id].content.parent_id] = [] unless parentid_map[projectid_map[p.id].content.parent_id]
            parentid_map[projectid_map[p.id].content.parent_id] << projectid_map[p.id]
          end
        end
      end
      # add parentid_map nodes to tree
      addnodes(root, parentid_map)
      Rails.logger.debug root.print_tree
      return root
    end

    def addnodes(root, parentid_map)
      # process nodes recursive and add them to it's parent
      root.children.each do |c|
        parentid_map[c.name].each do |n|
          c << n unless c.include?(n)
          addnodes(c, parentid_map)
        end if parentid_map[c.name]
      end
    end

    def projects(filter={})
      driver.map_to(Identity::Project).projects(filter)
    end

    def grant_project_user_role_by_role_name(project_id, user_id, role_name)
      role = service_user.find_role_by_name(role_name)
      driver.grant_project_user_role(project_id, user_id, role.id)
    end

    def grant_project_user_role(project_id, user_id, role_id)
      driver.grant_project_user_role(project_id, user_id, role_id)
    end

    def revoke_project_user_role(project_id, user_id, role_id)
      driver.revoke_project_user_role(project_id, user_id, role_id)
    end

    ##################### CREDENTIALS #########################
    def new_credential(attributes={})
      Identity::OsCredential.new(@driver, attributes)
    end

    def find_credential(id=nil)
      return nil if id.blank?
      driver.map_to(Identity::OsCredential).get_os_credential(id)
    end

    def credentials(options={})
      @user_credentials ||= driver.map_to(Identity::OsCredential).os_credentials(user_id: @current_user.id)
    end

    ####################### ROLES ###########################
    # current_user roles
    def roles
      @roles ||= driver.map_to(Identity::Role).roles
    end

    def find_role(id)
      return nil if id.blank?
      roles.select { |r| r.id==id }.first
    end

    def find_role_by_name(name)
      roles.select { |r| r.name==name }.first
    end

    def role_assignments(filter={})
      driver.map_to(Identity::RoleAssignment).role_assignments(filter)
    end

    def grant_domain_user_role(domain_id, user_id, role_id)
      driver.grant_domain_user_role(domain_id, user_id, role_id)
    end

    def revoke_domain_user_role(domain_id, user_id, role_id)
      driver.revoke_domain_user_role(domain_id, user_id, role_id)
    end

    ###################### TOKENS ###########################
    def validate_token(token)
      driver.validate(token) rescue false
    end

    ###################### USERS ##########################
    def users(filter={})
      driver.map_to(Identity::User).users(filter)
    end

    def find_user(id)
      driver.map_to(Identity::User).get_user(id)
    end
  end
end

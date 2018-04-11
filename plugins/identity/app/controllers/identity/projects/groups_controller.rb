module Identity
  module Projects
    class GroupsController < ::DashboardController
      before_action :load_roles, except: [:new]

      def new
        enforce_permissions('identity:project_group_create',{domain_id: @scoped_domain_id})
        @groups = service_user.identity.groups(domain_id: @scoped_domain_id)
      end

      def create
        enforce_permissions('identity:project_group_create',
                            domain_id: @scoped_domain_id)

        load_role_assignments
        @groups = service_user.identity.groups(domain_id: @scoped_domain_id)
        @group = @groups.select do |group|
          group.name == params[:group_name] || group.id == params[:group_name]
        end.first

        if @group.nil? || @group.id.nil?
          @error = 'Group not found.'
          render action: :new
        elsif @group_roles[@group.id]
          @error = 'Group is already assigned to this project.'
          render action: :new
        elsif @group.domain_id != @scoped_domain_id
          @error = 'Group is not a member of this domain.'
          render action: :new
        else
          render action: :create
        end
      end

      def members
        @members = begin
          service_user.identity.group_members(params[:group_id])
        rescue
          services.identity.group_members(params[:group_id])
        end
      end

      def index
        enforce_permissions('identity:project_group_list',
                            domain_id: @scoped_domain_id)
        load_role_assignments
      end

      def update
        enforce_permissions('identity:project_group_update',
                            domain_id: @scoped_domain_id)
        load_role_assignments
        available_role_ids = @roles.collect(&:id)

        # update changed roles
        updated_roles_group_ids = []
        params[:role_assignments].try(:each) do |group_id, new_group_role_ids|
          updated_roles_group_ids << group_id
          old_group_role_ids = (@group_roles[group_id] || { roles: [] })[:roles]
                               .collect { |role| role[:id] }

          role_ids_to_add = new_group_role_ids - old_group_role_ids
          role_ids_to_remove = old_group_role_ids - new_group_role_ids

          role_ids_to_add.each do |role_id|
            next unless available_role_ids.include?(role_id)
            begin
              service_user.identity.grant_project_group_role(
                @scoped_project_id, group_id, role_id
              )
            rescue
              nil
            end
          end
          role_ids_to_remove.each do |role_id|
            next unless available_role_ids.include?(role_id)
            begin
              service_user.identity.revoke_project_group_role(@scoped_project_id,
                                                     group_id, role_id)
            rescue
              nil
            end
          end
        end

        # remove roles
        (@group_roles.keys - updated_roles_group_ids).each do |group_id|
          role_ids_to_remove = (@group_roles[group_id] || {})[:roles]
                               .collect { |role| role[:id] }
          role_ids_to_remove.each do |role_id|
            next unless available_role_ids.include?(role_id)
            begin
              service_user.identity.revoke_project_group_role(@scoped_project_id,
                                                     group_id, role_id)
            rescue
              nil
            end
          end
        end

        audit_logger.info(current_user, "has updated group role assignments \
        for project #{@scoped_project_name} (#{@scoped_project_id})")

        redirect_to projects_groups_path
      end

      protected

      # FIXME: duplicated in MembersController
      def load_roles
        @roles = service_user.identity.roles.keep_if do |role|
          ALLOWED_ROLES.include?(role.name) || user_has_beta_role?(role.name)
        end.sort_by(&:name)
      end

      def user_has_beta_role?(role_name)
        BETA_ROLES.include?(role_name) && current_user.has_role?(role_name)
      end

      def load_role_assignments
        @role_assignments ||= service_user.identity.role_assignments(
          'scope.project.id' => @scoped_project_id,
          include_names: true,
          include_subtree: true
        )
        @group_roles ||= @role_assignments.each_with_object({}) do |ra, hash|
          group_id = (ra.group || {}).fetch('id', nil)
          project_id = (ra.scope || {}).fetch('project', {}).fetch('id', nil)
          # ignore user role assignments
          next unless group_id && project_id == @scoped_project_id
          hash[group_id] ||= { role_ids: [], roles: [],
                               name: ra.group.fetch('name', 'unknown') }
          hash[group_id][:roles] << { id: ra.role['id'],
                                      name: ra.role['name'] }
        end
        @group_roles.sort_by { |group_id, _age| group_id }
      end
    end
  end
end

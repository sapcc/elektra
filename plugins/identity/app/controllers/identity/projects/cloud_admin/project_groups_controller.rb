# frozen_string_literal: true

module Identity
  module Projects
    module CloudAdmin
      # This class implements project groups actions
      # Adding and removing of project groups.
      class ProjectGroupsController < ::DashboardController
        before_action :load_scope_and_roles

        def index
          enforce_permissions('identity:project_group_list', {})
          load_role_assignments(@project.id) if @project
        end

        def new
          enforce_permissions('identity:project_group_create', {})
          @groups = services.identity.groups(domain_id: @domain.id)
        end

        def create
          enforce_permissions('identity:project_group_create', {})

          @group = nil if params[:group_name].blank?
          @group ||= services.identity.groups(
            domain_id: @domain.id, name: params[:group_name]
          ).first
          @group ||= services.identity.find_group(params[:group_name])

          load_role_assignments(@project.id)
          @groups = services.identity.groups(domain_id: @domain.id)

          if @group.nil? || @group.id.nil?
            @error = 'Group not found.'
            render action: :new
          elsif @group_roles[@group.id]
            @error = 'Group is already assigned to this project.'
            render action: :new
          elsif @group.domain_id != @domain.id
            @error = 'Group is not a member of this domain.'
            render action: :new
          else
            render action: :create
          end
        end

        def update
          enforce_permissions('identity:project_group_update', {})

          load_role_assignments(@project.id)
          available_role_ids = @roles.collect(&:id)

          # update changed roles
          updated_roles_group_ids = []
          params[:role_assignments].try(:each) do |group_id, new_group_role_ids|
            updated_roles_group_ids << group_id
            old_group_role_ids = (@group_roles[group_id] || { roles: [] })[:roles].collect{|role| role[:id]}

            role_ids_to_add = new_group_role_ids - old_group_role_ids
            role_ids_to_remove = old_group_role_ids - new_group_role_ids

            role_ids_to_add.each do |role_id|
              next unless available_role_ids.include?(role_id)
              services.identity.grant_project_group_role(
                @project.id, group_id, role_id
              )
            end
            role_ids_to_remove.each do |role_id|
              next unless available_role_ids.include?(role_id)
              services.identity.revoke_project_group_role(
                @project.id, group_id, role_id
              )
            end
          end

          # remove roles
          (@group_roles.keys - updated_roles_group_ids).each do |group_id|
            role_ids_to_remove = (@group_roles[group_id] || {})[:roles]
                                 .collect { |role| role[:id] }
            role_ids_to_remove.each do |role_id|
              next unless available_role_ids.include?(role_id)
              services.identity.revoke_project_group_role(
                @project.id, group_id, role_id
              )
            end
          end

          audit_logger.info("Cloud admin #{current_user.name} \
          (#{current_user.id}) has updated group role assignments \
          for project #{@project.name} (#{@project.id})")

          redirect_to projects_cloud_admin_project_groups_path(project: @project.id)
        end

        protected

        # FIXME: duplicated in ProjectMembersController
        def load_scope_and_roles
          @domain, @project = services.identity.find_domain_and_project(
            params.permit(:domain, :project)
          )
          @roles = services.identity.roles.sort_by(&:name)
        end

        def load_role_assignments(project_id)
          @role_assignments ||= services.identity.role_assignments(
            'scope.project.id' => project_id,
            include_names: true,
            include_subtree: true
          )
          @group_roles ||= @role_assignments.each_with_object({}) do |ra, hash|
            group_id = (ra.group || {}).fetch('id', nil)
            role_project_id = (ra.scope || {}).fetch('project', {})
                                              .fetch('id', nil)
            # ignore user role assignments
            next unless group_id && role_project_id == project_id
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
end

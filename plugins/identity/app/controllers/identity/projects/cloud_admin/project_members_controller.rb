# frozen_string_literal: true

module Identity
  module Projects
    module CloudAdmin
      # This class implements methods add and remove for project members
      class ProjectMembersController < ::DashboardController
        before_action :load_scope_and_roles

        def index
          enforce_permissions('identity:project_member_list', {})
          load_role_assignments(@project.id) if @project
        end

        def new
          enforce_permissions('identity:project_member_create', {})
        end

        def create
          enforce_permissions('identity:project_member_create', {})
          @user = if params[:user_name].blank?
                    nil
                  else
                    begin
                      services.identity.users(domain_id: @domain.id,
                                                 name: params[:user_name]).first
                    rescue
                      services.identity.find_user(params[:user_name])
                    end
                  end

          load_role_assignments(@project.id)
          if @user.nil? || @user.id.nil?
            @error = 'User not found.'
            render action: :new
          elsif @user_roles[@user.id]
            @error = 'User is already a member of this project.'
            render action: :new
          elsif @user.domain_id != @domain.id
            @error = 'User is not a member of this domain.'
            render action: :new
          else
            render action: :create
          end
        end

        def update
          enforce_permissions('identity:project_member_update', {})
          load_role_assignments(@project.id)
          available_role_ids = @roles.collect(&:id)

          # update changed roles
          updated_roles_user_ids = []
          params[:role_assignments].try(:each) do |user_id, new_user_role_ids|
            updated_roles_user_ids << user_id
            old_user_role_ids = (@user_roles[user_id] || { roles: [] })[:roles]
                                .collect { |role| role[:id] }

            role_ids_to_add = new_user_role_ids - old_user_role_ids
            role_ids_to_remove = old_user_role_ids - new_user_role_ids

            role_ids_to_add.each do |role_id|
              if available_role_ids.include?(role_id)
                services.identity.grant_project_user_role(@project.id,
                                                             user_id, role_id)
              end
            end

            role_ids_to_remove.each do |role_id|
              if available_role_ids.include?(role_id)
                services.identity.revoke_project_user_role(@project.id,
                                                              user_id, role_id)
              end
            end
          end

          # remove roles
          (@user_roles.keys - updated_roles_user_ids).each do |user_id|
            role_ids_to_remove = (@user_roles[user_id] || {})[:roles]
                                 .collect { |role| role[:id] }
            role_ids_to_remove.each do |role_id|
              next unless available_role_ids.include?(role_id)
              services.identity.revoke_project_user_role(@project.id,
                                                            user_id, role_id)
            end
          end

          audit_logger.info("Cloud Admin #{current_user.name} \
          (#{current_user.id}) has updated user role assignments for \
          project #{@project.name} (#{@project.id})")
          redirect_to projects_cloud_admin_project_members_path(
            project: @project.id
          )
        end

        protected

        def load_project
          return unless params[:project]

          @domain = if params[:domain]
                      services.identity.domains(name: params[:domain].strip)
                                 .first ||
                        services.identity.find_domain(params[:domain].strip)
                    end
          @project = if @domain
                       services.identity.projects(
                         domain_id: @domain.id, name: params[:project].strip
                       ).first
                     end
          @project ||= services.identity.find_project(params[:project].strip)
          return unless @project
          @domain ||= services.identity.find_domain(@project.domain_id)
        end

        # FIXME: duplicated in ProjectGroupsController
        def load_scope_and_roles
          @domain, @project = services.identity.find_domain_and_project(
            params.permit(:domain, :project)
          )
          @roles = services.identity.roles.sort_by(&:name)
        end

        def load_role_assignments(project_id)
          @role_assignments ||= services.identity.role_assignments(
            'scope.project.id' => project_id, include_names: true
          )

          @user_roles ||= @role_assignments.each_with_object({}) do |ra, hash|
            user_id = (ra.user || {}).fetch('id', nil)
            role_project_id = (ra.scope || {}).fetch('project', {})
                                              .fetch('id', nil)
            # ignore group role assignments and other projects
            next unless user_id && role_project_id == project_id
            hash[user_id] ||= { role_ids: [], roles: [],
                                name: ra.user.fetch('name', 'unknown') }
            hash[user_id][:roles] << { id: ra.role['id'],
                                       name: ra.role['name'] }
          end
          @user_roles.sort_by { |user_id, _age| user_id }
        end
      end
    end
  end
end

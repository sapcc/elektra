# frozen_string_literal: true

module Identity
  module Projects
    # This class implements actions for project members.
    # It handles the adding and removing of role assignments on project.
    class MembersController < ::DashboardController
      before_filter :load_roles, except: [:new]

      def new
        enforce_permissions('identity:project_member_create',
                            domain_id: @scoped_domain_id)
      end

      def create
        enforce_permissions('identity:project_member_create',
                            domain_id: @scoped_domain_id)
        @user = if params[:user_name].blank?
                  nil
                else
                  begin
                    service_user.identity.users(domain_id: @scoped_domain_id,
                                                name: params[:user_name]).first
                  rescue
                    service_user.identity.find_user(params[:user_name])
                  end
                end
        load_role_assignments

        if @user.nil? || @user.id.nil?
          @error = 'User not found.'
          render action: :new
        elsif @user_roles[@user.id]
          @error = 'User is already a member of this project.'
          render action: :new
        elsif @user.domain_id != @scoped_domain_id
          @error = 'User is not a member of this domain.'
          render action: :new
        else
          render action: :create
        end
      end

      def index
        enforce_permissions('identity:project_member_list',
                            domain_id: @scoped_domain_id)
        load_role_assignments
      end

      def update
        enforce_permissions('identity:project_member_update',
                            domain_id: @scoped_domain_id)
        load_role_assignments
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
            next unless available_role_ids.include?(role_id)
            begin
              service_user.idenity.grant_project_user_role(@scoped_project_id,
                                                           user_id, role_id)
            rescue
              nil
            end
          end

          role_ids_to_remove.each do |role_id|
            next unless available_role_ids.include?(role_id)
            begin
              service_user.identity.revoke_project_user_role(@scoped_project_id,
                                                             user_id, role_id)
            rescue
              nil
            end
          end
        end

        # remove roles
        (@user_roles.keys - updated_roles_user_ids).each do |user_id|
          role_ids_to_remove = (@user_roles[user_id] || {})[:roles]
                               .collect { |role| role[:id] }
          role_ids_to_remove.each do |role_id|
            next unless available_role_ids.include?(role_id)
            begin
              service_user.identity.revoke_project_user_role(
                @scoped_project_id, user_id, role_id
              )
            rescue
              nil
            end
          end
        end

        audit_logger.info(current_user, "has updated user role assignments \
        for project #{@scoped_project_name} (#{@scoped_project_id})")
        redirect_to projects_members_path
      end

      protected

      # FIXME: duplicated in GroupsController
      def load_roles
        @roles = service_user.identity.roles.keep_if do |role|
          ALLOWED_ROLES.include?(role.name)
        end.sort_by(&:name)
      end

      def load_role_assignments
        @role_assignments ||= service_user.identity.role_assignments(
          'scope.project.id' => @scoped_project_id,
          include_names: true,
          include_subtree: true
        )

        @user_roles ||= @role_assignments.each_with_object({}) do |ra, hash|
          user_id = (ra.user || {}).fetch('id', nil)
          project_id = (ra.scope || {}).fetch('project', {}).fetch('id', nil)
          # ignore group role assignments and other projects

          next unless user_id && project_id == @scoped_project_id
          user_name = ra.user.fetch('name', 'unknown')
          # try to get full name from user profile stored in Elektra db
          user_profile = UserProfile.search_by_name(user_name).first
          user_description = user_profile.blank? ? '' : user_profile.full_name
          hash[user_id] ||= {
            role_ids: [],
            roles: [],
            name: user_name,
            description: user_description
          }
          hash[user_id][:roles] << {
            id: ra.role['id'],
            name: ra.role['name']
          }
        end
        @user_roles.sort_by { |user_id, _age| user_id }
      end
    end
  end
end

module Identity
  module Domains
    # This controller implemnts the workflow to create a project
    class CreateWizardController < DashboardController
      before_action :load_and_authorize_inquiry

      def new
        @project = services.identity.new_project
        @project.cost_control = {}
        return unless @inquiry
        @project.attributes = @inquiry.payload
      end

      def create
        project_params =
          params.fetch(:project, {}).merge(domain_id: @scoped_domain_id)
        cost_params = project_params.delete(:cost_control)

        # user is not allowed to create a project (maybe)
        # so use admin identity for that!
        @project = services.identity.new_project
        @project.attributes = project_params

        @project.enabled = @project.enabled == "true"

        @project.escape_attributes!

        if @project.save
          audit_logger.info(current_user, "has created", @project)

          if services.available?(:resource_management)
            # discover newly created projects
            # use cloud_admin because domain resource admin role is required for this call
            # rescue in case an exception happens so that the rest of the action is performed
            begin
              cloud_admin.resource_management.discover_projects(
                @scoped_domain_id,
              )
            rescue StandardError
              nil
            end
          end

          flash.now[:notice] = "Project #{@project.name} successfully created."
          if @inquiry
            if @inquiry.requester && @inquiry.requester.uid
              # give requester needed roles
              assign_needed_roles(@project.id, @inquiry.requester.uid)
            end

            inquiry =
              services.inquiry.set_inquiry_state(
                @inquiry.id,
                :approved,
                "Project #{@project.name} approved and \
              created by #{current_user.full_name}",
                current_user,
              )
            services.identity.grant_project_user_role_by_role_name(
              @project.id,
              inquiry.requester.uid,
              "admin",
            )
            render "identity/domains/create_wizard/create.js"
          else
            # there is no requiry -> current user is the creator of this
            # project. give current user all needed roles
            assign_needed_roles(@project.id, current_user.id)

            redirect_to :domain
          end
        else
          # put cost_params back into @project where the view can find them
          # to re-render the form
          @project.cost_control = cost_params unless cost_params.nil?

          flash.now[:error] = @project.errors.full_messages.to_sentence
          render action: :new
        end
      end

      def load_and_authorize_inquiry
        return if params[:inquiry_id].blank?
        @inquiry = services.inquiry.get_inquiry(params[:inquiry_id])

        if @inquiry
          enforce_permissions(
            "identity:project_create",
            project: {
              domain_id: @scoped_domain_id,
            },
          )
        else
          render template: "/identity/domains/create_wizard/not_found"
        end
      end

      protected

      def assign_needed_roles(project_id, user_id)
        %w[admin member network_admin resource_admin].each do |role_name|
          services.identity.grant_project_user_role_by_role_name(
            project_id,
            user_id,
            role_name,
          )
        end
      end
    end
  end
end

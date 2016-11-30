module Identity
  module Domains
    # This controller implemnts the workflow to create a project
    class CreateWizardController < DashboardController
      before_filter :load_and_authorize_inquiry

      def new
        @project = Identity::Project.new(nil,{})
        @project.cost_control = {}
        if @inquiry
          payload = @inquiry.payload
          @project.attributes = payload
        end
      end

      def create
        project_params = params.fetch(:project, {}).merge(domain_id: @scoped_domain_id)
        cost_params    = project_params.delete(:cost_control)

        # user is not allowed to create a project (maybe)
        # so use admin identity for that!
        @project = services.identity.new_project
        @project.attributes = project_params
        @project.enabled = @project.enabled == 'true'

        if @project.save
          services.identity.grant_project_user_role_by_role_name(@project.id, current_user.id, 'admin')
          services.identity.grant_project_user_role_by_role_name(@project.id, current_user.id, 'member')
          services.identity.clear_auth_projects_tree_cache

          audit_logger.info(current_user, "has created", @project)

          if services.available?(:cost_control)

            cost_params.merge!(id: @project.id)

            # normalize value from inherited cost object checkbox to boolean
            cost_params['cost_object_inherited'] = cost_params.fetch('cost_object_inherited', '')=='1'

            cost_control_masterdata = services.cost_control.new_project_masterdata(cost_params)
            if cost_control_masterdata.save
              audit_logger.info(current_user, "has assigned", @project, "to cost center #{cost_control_masterdata.cost_object_string}")
            end
          end

          flash[:notice] = "Project #{@project.name} successfully created."
          if @inquiry
            inquiry = services.inquiry.set_inquiry_state(@inquiry.id, :approved, "Project #{@project.name} approved and created by #{current_user.full_name}")
            services.identity.grant_project_user_role_by_role_name(@project.id, inquiry.requester.uid, 'admin')
            render 'identity/domains/create_wizard/create.js'
          else
            redirect_to :domain
          end
        else
          # put cost_params back into @project where the view can find them to re-render the form
          @project.cost_control = cost_params

          flash.now[:error] = @project.errors.full_messages.to_sentence
          render action: :new
        end
      end

      def load_and_authorize_inquiry
        return if params[:inquiry_id].blank?
        @inquiry = services.inquiry.get_inquiry(params[:inquiry_id])

        if @inquiry
          enforce_permissions("identity:project_create", {project: {domain_id: @scoped_domain_id} })
        else
          render template: '/identity/domains/create_wizard/not_found'
        end
      end
    end
  end
end

module Identity
  module Projects
    # This controller implemnts the workflow to create a project
    class CreateWizardController < DashboardController
      before_filter :load_and_authorize_inquiry
      
      def new
        @project = services.identity.new_project
        @project.attributes = @inquiry.payload
      end
      
      def create
        # user is not allowed to create a project (maybe)
        # so use admin identity for that!
        @project = Admin::IdentityService.new_project
        @project.attributes = params.fetch(:project,{}).merge(domain_id: @scoped_domain_id)

        if @project.save
          services.inquiry.status_close(@inquiry.id, "Project #{@project.name} successfully created.")

          Admin::IdentityService.grant_project_role(current_user.id,@project.id,'admin')
          flash[:notice] = "Project #{@project.name} successfully created."
          redirect_to plugin('identity').project_path(project_id: @project.friendly_id)
        else
          flash[:error] = @project.errors.full_messages.to_sentence
          render action: :new
        end
      end
      
      def load_and_authorize_inquiry
        @inquiry = services.inquiry.get_inquiry(params[:inquiry_id])
        
        if @inquiry
          unless current_user.is_allowed?("identity:create_wizard_create",{inquiry: {requester_uid: @inquiry.requester.uid} })
            render template: '/dashboard/not_authorized' 
          end
        else
          render template: '/identity/projects/create_wizard/not_found'
        end 
      end
    end
  end
end
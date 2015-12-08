module Identity
  module Projects
    # This controller implemnts the workflow to create a project
    class CreateWizardController < DashboardController
      before_filter :load_and_authorize_inquiry
      
      def new
        @inquiry_id = params[:inquiry_id]
        
        
        #if current_user.is_allowed?("identity:create_wizard_new",{inquiry: {requestor_uid: "u-6eeb6ad5c"} })
        
          @project = services.identity.new_project
        
          # GOOD
          payload = services.inquiry.payload(@inquiry_id)
          @project.attributes = payload
        # end
      end
      
      def create
        # user is not allowed to create a project (maybe)
        # so use admin identity for that!
        @project = Admin::IdentityService.new_project
        @project.attributes = params.fetch(:project,{}).merge(domain_id: @scoped_domain_id)

        if @project.save
          @inquiry_id = params[:inquiry_id]
          if @inquiry_id
            services.inquiry.status_close(@inquiry_id, "Project #{@project.name} successfully created.")
          end
          Admin::IdentityService.grant_project_role(current_user.id,@project.id,'admin')
          flash[:notice] = "Project #{@project.name} successfully created."
          redirect_to plugin('identity').project_path(project_id: @project.friendly_id)
        else
          flash[:error] = @project.errors.full_messages.to_sentence
          render action: :new
        end
      end
      
      def load_and_authorize_inquiry
        #@inquiry = services.inquiry.inquiry(params[:inquiry_id])
        unless current_user.is_allowed?("identity:create_wizard_new",{inquiry: {requestor_uid: "bad"} })
          render template: '/dashboard/not_authorized' 
        end  
      end
    end
  end
end
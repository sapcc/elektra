module Identity
  module Projects
    # This controller implemnts the workflow to create a project
    class CreateWizardController < DashboardController
      def new
        @project = services.identity.new_project
        
        # GOOD
        payload = services.inquiry.payload(params[:inquiry_id])
        @project.attributes = payload
        @project.inquiry_id = params[:inquiry_id]
        
        # BAD (test)
        #payload = Inquiry::Inquiry.first.payload
        #@project.attributes=payload
      end
      
      def create
        # user is not allowed to create a project (maybe)
        # so use admin identity for that!
        @project = Admin::IdentityService.new_project
        @project.attributes = params.fetch(:project,{}).merge(domain_id: @scoped_domain_id)

        if @project.save
          services.inquiry.status_close(params[:project][:inquiry_id], "Project #{@project.name} successfully created.")
          Admin::IdentityService.grant_project_role(current_user.id,@project.id,'admin')
          flash[:notice] = "Project #{@project.name} successfully created."
          redirect_to plugin('identity').project_path(project_id: @project.friendly_id)
        else
          flash[:error] = @project.errors.full_messages.to_sentence
          render action: :new
        end
      end
    end
  end
end
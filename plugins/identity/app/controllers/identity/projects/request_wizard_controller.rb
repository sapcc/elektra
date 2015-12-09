module Identity
  module Projects
    # This controller implemnts the workflow to create a project request
    class RequestWizardController < ::DashboardController
      def new
        @project = services.identity.new_project
      end
      
      def create
        @project = services.identity.new_project
        @project.attributes=params.fetch(:project,{}).merge(domain_id: @scoped_domain_id)
        
        success = false
        
        if @project.valid?
          inq = services.inquiry.inquiry_create(
            'project', 
            'Create a project', 
            current_user, 
            @project.attributes.to_json, 
            Admin::IdentityService.list_scope_admins(domain_id: @scoped_domain_id,project_id:@scoped_project_id), 
            {
              "approved": {
                "name": "Create",
                "action": "#{request.protocol}#{request.host_with_port}#{plugin('identity').domain_path}?overlay=#{plugin('identity').projects_create_path}"
              }
            }
          )
          success = inq.save
        end
        
        if success
          render template: 'identity/projects/request_wizard/create.js'
        else
          render action: :new
        end
      end
    end
  end
end

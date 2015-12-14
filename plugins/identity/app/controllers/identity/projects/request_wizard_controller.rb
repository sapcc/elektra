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

        inquiry_id = nil
        
        if @project.valid?
          inquiry_id = services.inquiry.inquiry_create(
            'project', 
            'Create a project', 
            current_user, 
            @project.attributes.to_json, 
            Admin::IdentityService.list_scope_admins(domain_id: @scoped_domain_id,project_id:@scoped_project_id), 
            {
              "approved": {
                "name": "Create",
                "action": "#{plugin('identity').domain_url(host: request.host_with_port, protocol: request.protocol)}?overlay=#{plugin('identity').projects_create_path}"
              }
            }
          )
        end
        
        if inquiry_id
          render template: 'identity/projects/request_wizard/create.js'
        else
          render action: :new
        end
      end
    end
  end
end

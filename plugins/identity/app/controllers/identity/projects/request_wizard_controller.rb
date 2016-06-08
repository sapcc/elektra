module Identity
  module Projects
    # This controller implemnts the workflow to create a project request
    class RequestWizardController < ::DashboardController
      before_filter :load_and_authorize_inquiry, only:[:edit,:update]
      
      before_filter do
        enforce_permissions("identity:project_request",{domain_id: @scoped_domain_id})
      end
      
      def new
        @project = Identity::Project.new(nil,{})
        @project.enabled = true
        @project.parent_id = @scoped_project_id #params[:parent_project_id] if params[:parent_project_id]
        @project.parent_name = @scoped_project_name #params[:parent_project_name] if params[:parent_project_name]
      end

      def create
        @project = Identity::Project.new(nil,{})
        @project.attributes=params.fetch(:project, {}).merge(domain_id: @scoped_domain_id)

        inquiry = nil

        if @project.valid?
          begin
            inquiry = services.inquiry.create_inquiry(
                'project',
                "#{@project.name} - #{@project.description}",
                current_user,
                @project.attributes.to_json,
                service_user.list_scope_admins(domain_id: @scoped_domain_id),
                {
                    "approved": {
                        "name": "Approve",
                        "action": "#{plugin('identity').domain_url(host: request.host_with_port, protocol: request.protocol)}?overlay=#{plugin('identity').domains_create_project_path(project_id: nil)}"
                    }
                }
            )
            unless inquiry.errors?
              flash.now[:notice] = "Project request successfully created"
              render template: 'identity/projects/request_wizard/create.js'
            else
              render action: :new
            end
          rescue => e
            @project.errors.add("message",e.message)
            render action: :new
          end
        else
          render action: :new
        end
      end
    end

    def edit
      @project = Identity::Project.new(nil,{})
      @project.attributes = @inquiry.payload
    end

    def update
      # user is not allowed to create a project (maybe)
      # so use admin identity for that!
      @project = Identity::Project.new(nil,{})
      @project.attributes = params.fetch(:project, {}).merge(domain_id: @scoped_domain_id)
      if @project.valid?
        inquiry = services.inquiry.change_inquiry(
            id: @inquiry.id,
            description: @project.description,
            payload: @project.attributes.to_json
        )
        unless inquiry.errors?
          render template: 'identity/projects/request_wizard/create.js'
        else
          render action: :edit
        end
      else
        render action: :edit
      end
    end

    def load_and_authorize_inquiry
      @inquiry = services.inquiry.get_inquiry(params[:inquiry_id])

      if @inquiry
        unless current_user.is_allowed?("identity:project_request", {domain_id:@scoped_domain_id})
          render template: '/dashboard/not_authorized'
        end
      else
        render template: '/identity/projects/create_wizard/not_found'
      end
    end

  end
end

module Identity
  class ProjectsController < DashboardController
    before_filter :get_project_id,  except: [:index, :create, :new]
    before_filter do
      @scoped_project_fid = params[:project_id] || @project_id
    end

    def index
      @projects = services.identity.auth_projects(@scoped_domain_id)
      respond_to do |format|
        format.js
        format.html
      end
    end

    def show
      @current_project = services.identity.find_project(@project_id, :subtree_as_list)
      @instances = services.compute.servers(tenant_id: @current_project.id) rescue []
    end
    
    def wizard
      @project = services.identity.new_project
    end
    
    def wizard_create
      @project = services.identity.new_project
      @project.attributes=params.fetch(:project,{}).merge(domain_id: @scoped_domain_id)
      
      inq = services.inquiry.inquiry_create(
        'project', 
        'Create a project', 
        current_user, 
        @project.attributes.to_json, 
        Admin::IdentityService.list_scope_admins(domain_id: @scoped_domain_id,project_id:@scoped_project_id), 
        nil
      )
      if inq.save
        render template: 'identity/projects/wizard_create.js'
      else
        render action: :wizard
      end
    end

    def destroy
      project = services.identity.find_project(@project_id)
      
      if project.destroy
        flash[:notice] = "Project successfully deleted."
      else
        flash[:error] = project.errors.full_messages.to_sentence #"Something when wrong when trying to delete the project"
      end

      redirect_to projects_path
    end

    private

    def get_project_id
      @project_id = params[:id] || params[:project_id]
      entry = FriendlyIdEntry.find_by_class_scope_and_key_or_slug('Project',@scoped_domain_id,@project_id)
      @project_id = entry.key if entry
    end
  end
end

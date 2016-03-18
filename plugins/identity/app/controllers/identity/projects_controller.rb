module Identity
  class ProjectsController < DashboardController

    before_filter :get_project_id,  except: [:index, :create, :new]
    before_filter do
      @scoped_project_fid = params[:project_id] || @project_id
    end

    authorization_required(context:'identity')

    def index
      @projects = @user_domain_projects

      respond_to do |format|
        format.html {
          if params[:partial]
            render partial: 'projects', locals: {projects: @projects, remote_links: true}, layout: false
          else
            render action: :index
          end
        }
        format.js
      end

    end

    def show
    end

    def edit
      @project = services.identity.find_project(@project_id)
    end

    def update
      @project = services.identity.find_project(@project_id)
      @project.attributes = params[:project]
      if @project.save
        flash[:notice] = "Project #{@project.name} successfully updated."
        redirect_to plugin('identity').project_path
      else
        flash[:error] = @project.errors.full_messages.to_sentence
        render action: :edit
      end
    end

    def destroy
      project = services.identity.find_project(@project_id)

      if project.destroy
        flash[:notice] = "Project successfully deleted."
      else
        flash[:error] = project.errors.full_messages.to_sentence #"Something when wrong when trying to delete the project"
      end

      redirect_to plugin('identity').projects_path
    end

    def api_endpoints
      @token = current_user.token
      @webcli_endpoint = current_user.service_url("webcli")
      @identity_url = current_user.service_url("identity")
    end

    private

    def get_project_id
      @project_id = params[:id] || params[:project_id]
      entry = FriendlyIdEntry.find_by_class_scope_and_key_or_slug('Project',@scoped_domain_id,@project_id)
      @project_id = entry.key if entry
    end
  end
end

module Identity
  class ProjectsController < ::DashboardController

    before_filter :get_project_id,  except: [:index, :create, :new]
    before_filter do
      @scoped_project_fid = params[:project_id] || @project_id
    end

    authorization_required(context:'identity', additional_policy_params: {project: Proc.new { {id: @project_id, domain_id: @scoped_domain_id} } } )

    def user_projects
      @projects = @user_domain_projects.collect{ |project| ::Identity::Project.new(@driver, project.attributes.merge(id:project.id)) }

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
      params[:project][:enabled] = (params[:project][:enabled]==true or params[:project][:enabled]=='true') ? true : false
      @project = services.identity.find_project(@project_id)
      @project.attributes = params[:project]
    
      if @project.valid? && service_user.update_project(@project_id,@project.attributes)
        # audit_logger.info("User #{current_user.name} (#{current_user.id}) has updated project #{@project.name} (#{@project.id})")
        # audit_logger.info(user: current_user, has: "updated", project: @project)
        audit_logger.info(current_user, "has updated", @project)
        
        flash[:notice] = "Project #{@project.name} successfully updated."
        redirect_to plugin('identity').project_path
      else
        flash.now[:error] = @project.errors.full_messages.to_sentence
        render action: :edit
      end
    end

    def destroy
      response = service_user.delete_project(@project_id)
      
      if response
        audit_logger.info(current_user, "has deleted project", @project_id)
        flash[:notice] = "Project successfully deleted."
        redirect_to plugin('identity').domain_path
      else
        flash[:error] = response #"Something when wrong when trying to delete the project"
        redirect_to plugin('identity').project_path
      end
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

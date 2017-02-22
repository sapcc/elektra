module Identity
  class ProjectsController < ::DashboardController
    before_filter :project_id_required, except: [:index, :create, :new, :user_projects]
    before_filter :get_project_id,  except: [:index, :create, :new]

    before_filter :check_wizard_status, only: [:show]
    before_filter :load_and_update_wizard_status, only: [:show_wizard]

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

    def show_wizard
    end

    def edit
      @project = services.identity.find_project(@project_id)
    end

    def update
      params[:project][:enabled] = (params[:project][:enabled]==true or params[:project][:enabled]=='true') ? true : false
      @project = services.identity.find_project(@project_id)
      @project.attributes = params[:project]
      @project.domain_id=@scoped_domain_id

      if @project.valid? && service_user.update_project(@project_id,@project.attributes)
        # audit_logger.info("User #{current_user.name} (#{current_user.id}) has updated project #{@project.name} (#{@project.id})")
        # audit_logger.info(user: current_user, has: "updated", project: @project)
        audit_logger.info(current_user, "has updated", @project)

        entry = FriendlyIdEntry.update_project_entry(@project)
        flash[:notice] = "Project #{@project.name} successfully updated."
        redirect_to plugin('identity').project_path(project_id: (entry.nil? ? @project.id : entry.slug))
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
        redirect_to plugin('identity').domain_path(project_id: nil)
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

    def download_openrc
      @token = current_user.token
      @webcli_endpoint = current_user.service_url("webcli")
      @identity_url = current_user.service_url("identity")

      out_data = "export OS_AUTH_URL=#{@identity_url}\n" \
        "export OS_IDENTITY_API_VERSION=3\n" \
        "export OS_PROJECT_NAME=\"#{@scoped_project_name}\"\n" \
        "export OS_PROJECT_DOMAIN_NAME=\"#{@scoped_domain_name}\"\n" \
        "export OS_USERNAME=#{current_user.name}\n" \
        "export OS_USER_DOMAIN_NAME=\"#{@scoped_domain_name}\"\n" \
        "echo \"Please enter your OpenStack Password: \"\n" \
        "read -sr OS_PASSWORD_INPUT\n" \
        "export OS_PASSWORD=$OS_PASSWORD_INPUT\n" \
        "export OS_REGION_NAME=#{current_region}\n" \

      send_data( out_data, type:'text/plain', filename:"openrc-#{@scoped_domain_name}-#{@scoped_project_name}",dispostion:'inline',status: :ok )

    end

    private

    def get_project_id
      @project_id = params[:id] || params[:project_id]
      entry = FriendlyIdEntry.find_by_class_scope_and_key_or_slug('Project',@scoped_domain_id,@project_id)
      @project_id = entry.key if entry
    end

    def check_wizard_status
      @active_project_profile = ProjectProfile.find_or_create_by_project_id(@scoped_project_id)
      unless @active_project_profile.wizard_finished?
        redirect_to plugin('identity').project_wizard_url
      end
    end

    def load_and_update_wizard_status
      if @active_project_profile = ProjectProfile.find_or_create_by_project_id(@scoped_project_id)
        if services.resource_management.has_project_quotas?
          @active_project_profile.update_wizard_status('resource_management',ProjectProfile::STATUS_DONE)
        else
          # try to find a quota inquiry and get status of it
          @quota_inquiry = services.inquiry.get_inquiries({
            kind: 'project_quota_package',
            project_id: @scoped_project_id,
            domain_id: @scoped_domain_id
          }).first

          @active_project_profile.update_wizard_status('resource_management',nil)
        end

        @billing_data = services.cost_control.find_project_masterdata(@scoped_project_id)
        if @billing_data and @billing_data.cost_object_id
          @active_project_profile.update_wizard_status('cost_control',ProjectProfile::STATUS_DONE)
        else
          @active_project_profile.update_wizard_status('cost_control',nil)
        end

        @floatingip_network = services.networking.domain_floatingip_network(@scoped_domain_name)
        @rbacs = service_user.cloud_admin_service(:networking).rbacs({
          object_id: @floatingip_network.id,
          object_type: 'network',
          target_tenant: @scoped_project_id
        })

        if @rbacs.length>0
          @active_project_profile.update_wizard_status('networking',ProjectProfile::STATUS_DONE)
        else
          @active_project_profile.update_wizard_status('networking',nil)
        end

        #byebug
      end
    end
  end
end

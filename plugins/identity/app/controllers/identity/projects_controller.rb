module Identity
  class ProjectsController < ::DashboardController
    before_filter :project_id_required, except: [:index, :create, :new, :user_projects]
    before_filter :get_project_id,  except: [:index, :create, :new]

    # check wizard state and redirect unless finished
    before_filter :check_wizard_status, only: [:show]

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

    def view
      @project = services.identity.find_project(@project_id, [:subtree_as_ids, :parents_as_ids])
    end

    def show_wizard
      load_and_update_wizard_status if request.xhr?

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
      #### Disable project delete for now
      #
      # # first close all open and rejeced requests
      # inquirys = Inquiry::Inquiry.where(:domain_id => @scoped_domain_id, :project_id => @scoped_project_id, :aasm_state => ['open','rejected'])
      # inquirys.each do |inquiry|
      #   state_change_result = inquiry.change_state(:closed, 'Closed, because project was deleted!', current_user)
      #   unless state_change_result
      #     flash[:error] = "Something went wrong when trying to close all open or rejected requests for this project"
      #     redirect_to plugin('identity').project_path
      #   end
      # end
      #
      # # second delete the project itself
      # response = service_user.delete_project(@project_id)
      # if response
      #   audit_logger.info(current_user, "has deleted project", @project_id)
      #   flash[:notice] = "Project successfully deleted."
      #   redirect_to plugin('identity').domain_path(project_id: nil)
      # else
      #   flash[:error] = response #"Something when wrong when trying to delete the project"
      #   redirect_to plugin('identity').project_path
      # end
      flash.now[:error] = "Deleting projects is currently not allowed because it creates orphaned dependant objects in backend services."
      render action: :show
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
      unless (@scoped_domain_name=='ccadmin' and @scoped_project_name=='cloud_admin')
        service_names = ["cost_control","networking","resource_management"].keep_if do |name|
          services.available?(name.to_sym)
        end
        project_profile = ProjectProfile.find_or_create_by_project_id(@scoped_project_id)

        unless project_profile.wizard_finished?(service_names)
          redirect_to plugin('identity').project_wizard_url
        end
      end
    end

    def load_and_update_wizard_status
      @wizard_finished = true
      @project_profile = ProjectProfile.find_or_create_by_project_id(@scoped_project_id)

      # for all services do
      ['resource_management','cost_control','networking'].each do |service_name|
        if services.available?(service_name.to_sym)
          # set instance variable service available to true
          self.instance_variable_set("@#{service_name}_service_available",true)
          unless @project_profile.wizard_finished?(service_name)
            # update wizard status for current service
            @wizard_finished &= begin
              self.send("update_#{service_name}_wizard_status")
            rescue => e
              self.instance_variable_set("@#{service_name}_service_available",false)
              false
            end
          end
        end
      end
    end

    ################### HELPER METHODS #########################
    def update_resource_management_wizard_status
      if services.resource_management.has_project_quotas?
        @project_profile.update_wizard_status('resource_management',ProjectProfile::STATUS_DONE)
      else
        # try to find a quota inquiry and get status of it
        quota_inquiries = services.inquiry.get_inquiries({
          kind: 'project_quota_package',
          project_id: @scoped_project_id,
          domain_id: @scoped_domain_id
        })

        quota_inquiries = quota_inquiries.select{|quota_inquiry| quota_inquiry.aasm_state!='closed'}

        if quota_inquiries.length>0
          approved_inquiries = quota_inquiries.select{|quota_inquiry| quota_inquiry.aasm_state=='approved'}
          status = approved_inquiries.length>0 ? ProjectProfile::STATUS_DONE : ProjectProfile::STATUS_PENDING
          inquiry = if approved_inquiries.length>0
            approved_inquiries.first
          else
            quota_inquiries.first
          end

          @project_profile.update_wizard_status(
            'resource_management',
            status,
            {inquiry_id: inquiry.id, aasm_state: inquiry.aasm_state, package: inquiry.payload["package"]}
          )
        else
          @project_profile.update_wizard_status('resource_management',nil)
        end
      end
      @project_profile.wizard_finished?("resource_management")
    end

    def update_cost_control_wizard_status
      billing_data = service_user.domain_admin_service(:cost_control).find_project_masterdata(@scoped_project_id)

      if billing_data and billing_data.cost_object_id
        @project_profile.update_wizard_status(
          'cost_control',
          ProjectProfile::STATUS_DONE,
          {cost_object: billing_data.cost_object_id, type: billing_data.cost_object_type }
        )
      else
        @project_profile.update_wizard_status('cost_control',nil)
      end
      @project_profile.wizard_finished?("cost_control")
    end

    def update_networking_wizard_status
      if current_user.has_role?('admin') and !current_user.has_role?('network_admin')
        network_admin_role = services.identity.grant_project_user_role_by_role_name(@scoped_project_id, current_user.id, 'network_admin')
        # Hack: extend current_user context to add the new assigned role
        current_user.context["roles"] << { "id" => network_admin_role.id, "name" => network_admin_role.name }
      end

      networking_service = service_user.cloud_admin_service(:networking)
      floatingip_network = networking_service.domain_floatingip_network(@scoped_domain_name)
      rbacs = if floatingip_network
        networking_service.rbacs({
          object_id: floatingip_network.id,
          object_type: 'network',
          target_tenant: @scoped_project_id
        })
      else
        []
      end

      if rbacs.length>0
        @project_profile.update_wizard_status('networking',ProjectProfile::STATUS_DONE)
      else
        @project_profile.update_wizard_status('networking',nil)
      end
      @project_profile.wizard_finished?("networking")
    end
  end
end

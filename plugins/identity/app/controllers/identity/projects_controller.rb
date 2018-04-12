# frozen_string_literal: true

module Identity
  # This class implements project actions
  class ProjectsController < ::DashboardController
    before_action :project_id_required, except: %i[index create new user_projects]
    before_action :get_project_id,  except: %i[index create new]

    # check wizard state and redirect unless finished
    before_action :check_wizard_status, only: [:show]

    before_action do
      @scoped_project_fid = params[:project_id] || @project_id
    end

    authorization_required(
      context: 'identity', additional_policy_params: {
        project: proc { { id: @project_id, domain_id: @scoped_domain_id } }
      }
    )

    def user_projects
      @projects = @user_domain_projects

      respond_to do |format|
        format.html do
          if params[:partial]
            render partial: 'projects',
                   locals: { projects: @projects, remote_links: true },
                   layout: false
          else
            render action: :index
          end
        end
        format.js
      end
    end

    def show
      @subprojects = []
      if @user_domain_projects
        @subprojects = @user_domain_projects.select { |pr| pr.parent_id == @scoped_project_id }
      end
    end

    def view
      @project = services.identity.find_project(
        @project_id, subtree_as_ids: true, parents_as_ids: true
      )
    end

    def show_wizard
      load_and_update_wizard_status if request.xhr?
    end

    def edit
      @project = services.identity.find_project(@project_id)
    end

    def update
      params[:project][:enabled] = params[:project][:enabled] == true ||
                                   params[:project][:enabled] == 'true'
      @project = service_user.identity.new_project(params[:project])
      @project.id = @project_id
      @project.domain_id = @scoped_domain_id
      if @project.save &&
        # has updated project #{@project.name} (#{@project.id})")
        # audit_logger.info(user: current_user, has: "updated",
        #                   project: @project)
        audit_logger.info(current_user, 'has updated', @project)

        flash[:notice] = "Project #{@project.name} successfully updated."
        redirect_to plugin('masterdata_cockpit').project_masterdata_path(project_id: @project.id)
      else
        flash.now[:error] = @project.errors.full_messages.to_sentence
        render action: :edit
      end
    end

    def destroy
      flash.now[:error] = 'Deleting projects is currently not allowed because \
      it creates orphaned dependant objects in backend services.'
      render action: :show
    end

    def api_endpoints
      @token = current_user.token
      @webcli_endpoint = current_user.service_url('webcli')
      @identity_url = current_user.service_url('identity')
    end

    def download_openrc
      @token = current_user.token
      @webcli_endpoint = current_user.service_url('webcli')
      @identity_url = current_user.service_url('identity')

      out_data = "export OS_AUTH_URL=#{@identity_url}\n" \
        "export OS_IDENTITY_API_VERSION=3\n" \
        "export OS_PROJECT_NAME=\"#{@scoped_project_name}\"\n" \
        "export OS_PROJECT_DOMAIN_NAME=\"#{@scoped_domain_name}\"\n" \
        "export OS_USERNAME=#{current_user.name}\n" \
        "export OS_USER_DOMAIN_NAME=\"#{@scoped_domain_name}\"\n" \
        "if [ -z OS_PASSWORD ]; then\n" \
        "  echo \"Please enter your OpenStack Password: \"\n" \
        "  read -sr OS_PASSWORD_INPUT\n" \
        "  export OS_PASSWORD=$OS_PASSWORD_INPUT\n" \
        "endif\n" \
        "export OS_REGION_NAME=#{current_region}\n" \

      send_data(
        out_data,
        type: 'text/plain',
        filename: "openrc-#{@scoped_domain_name}-#{@scoped_project_name}",
        dispostion: 'inline',
        status: :ok
      )
    end

    private

    def get_project_id
      @project_id = params[:id] || params[:project_id]
      entry = FriendlyIdEntry.find_by_class_scope_and_key_or_slug(
        'Project', @scoped_domain_id, @project_id
      )
      @project_id = entry.key if entry
    end

    def check_wizard_status
      return if %w[ccadmin cloud_admin].include?(@scoped_domain_name)

      # for all services that implements a wizard integration do
      # check the order in /elektra/plugins/identity/spec/controllers/projects_controller_spec.rb
      service_names = %w[masterdata_cockpit networking resource_management].keep_if do |name|
        services.available?(name.to_sym)
      end

      project_profile = ProjectProfile.find_or_create_by_project_id(@scoped_project_id)

      return if project_profile.wizard_finished?(service_names)
      redirect_to plugin('identity').project_wizard_url
    end

    def load_and_update_wizard_status
      @wizard_finished = true
      @project_profile = ProjectProfile.find_or_create_by_project_id(@scoped_project_id)

      # for all services that implements a wizard integration do
      # check the order in /elektra/plugins/identity/spec/controllers/projects_controller_spec.rb
      %w[resource_management masterdata_cockpit networking].each do |service_name|
        next unless services.available?(service_name.to_sym)
        # set instance variable service available to true
        instance_variable_set("@#{service_name}_service_available", true)

        next if @project_profile.wizard_finished?(service_name)
        # update wizard status for current service
        @wizard_finished &= begin
          send("update_#{service_name}_wizard_status")
        rescue => _e
          instance_variable_set("@#{service_name}_service_available", false)
          false
        end
      end
    end

    ################### HELPER METHODS #########################
    def update_resource_management_wizard_status
      if services.resource_management.has_project_quotas?(@scoped_domain_id, @scoped_project_id)
        @project_profile.update_wizard_status('resource_management',ProjectProfile::STATUS_DONE)
      else
        # try to find a quota inquiry and get status of it
        quota_inquiries = services.inquiry.get_inquiries({
          kind: 'project_quota_package',
          project_id: @scoped_project_id,
          domain_id: @scoped_domain_id
        })

        quota_inquiries = quota_inquiries.select{|quota_inquiry| quota_inquiry.aasm_state!='closed'}

        if quota_inquiries.length.positive?
          approved_inquiries = quota_inquiries.select do |quota_inquiry|
            quota_inquiry.aasm_state == 'approved'
          end
          status = approved_inquiries.length.positive? ? ProjectProfile::STATUS_DONE : ProjectProfile::STATUS_PENDING
          inquiry = if approved_inquiries.length.positive?
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
          @project_profile.update_wizard_status('resource_management', nil)
        end
      end
      @project_profile.wizard_finished?('resource_management')
    end

    def update_masterdata_cockpit_wizard_status
      project_masterdata = nil
      @project_masterda_is_complete = false
      @project_masterdata_missing_attributes = nil
      begin
        project_masterdata = services.masterdata_cockpit.get_project(@scoped_project_id)
        # @project_masterda_is_complete is used in plugins/identity/app/views/identity/projects/_wizard_steps.html.haml
        @project_masterda_is_complete =  project_masterdata.is_complete
      rescue
        # the api will return with 404 if no masterdata was found all other cases will return false -> service not available
        #if e.code == 404
        #  return true
        #else
        #  return false
        #end
      end

      if project_masterdata && @project_masterda_is_complete
        @project_profile.update_wizard_status(
          'masterdata_cockpit', ProjectProfile::STATUS_DONE
        )
      elsif project_masterdata && !@project_masterda_is_complete
        # @project_masterdata_missing_attributes is used in plugins/identity/app/views/identity/projects/_wizard_steps.html.haml
        @project_masterdata_missing_attributes = project_masterdata.missing_attributes
        @project_profile.update_wizard_status('masterdata_cockpit', nil)
      else
        @project_profile.update_wizard_status('masterdata_cockpit', nil)
      end

      @project_profile.wizard_finished?('masterdata_cockpit')
    end

    def update_networking_wizard_status
      if current_user.has_role?('admin') && !current_user.has_role?('network_admin')
        network_admin_role = services.identity.grant_project_user_role_by_role_name(@scoped_project_id, current_user.id, 'network_admin')
        # Hack: extend current_user context to add the new assigned role
        current_user.context['roles'] << { 'id' => network_admin_role.id, 'name' => network_admin_role.name }
      end

      networking_service = cloud_admin.networking
      floatingip_network = networking_service
                           .domain_floatingip_network(@scoped_domain_name)
      rbacs = if floatingip_network
                networking_service.rbacs(
                  object_id: floatingip_network.id,
                  object_type: 'network',
                  target_tenant: @scoped_project_id
                )
              else
                []
              end

      if rbacs.length.positive?
        @project_profile.update_wizard_status('networking', ProjectProfile::STATUS_DONE)
      else
        @project_profile.update_wizard_status('networking', nil)
      end
      @project_profile.wizard_finished?('networking')
    end
  end
end

# frozen_string_literal: true

module Identity
  # This class implements project actions
  class ProjectsController < ::DashboardController
    before_action :project_id_required, except: %i[index create new]
    before_action :get_project_id,  except: %i[index create new show view show_wizard]

    # load @project because we do not want to use the @active_project from the object cache
    # in case the description was changed we want to show the user the changes immediately
    before_action :get_project, only: [:show, :view, :show_wizard]

    # check wizard state and redirect unless finished
    before_action :check_wizard_status, only: [:show]
    before_action :load_project_resource, only: [:show, :show_wizard]

    before_action do
      @scoped_project_fid = params[:project_id] || @project_id
    end

    authorization_required(
      context: 'identity', additional_policy_params: {
        project: proc { { id: @project_id, domain_id: @scoped_domain_id } }
      }
    )

    def show
    end

    def view
    end

    def show_wizard
      load_and_update_wizard_status if request.xhr?
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
        "echo \"Please enter your OpenStack Password: \"\n" \
        "read -sr OS_PASSWORD_INPUT\n" \
        "export OS_PASSWORD=$OS_PASSWORD_INPUT\n" \
        "export OS_REGION_NAME=#{current_region}\n" \
        "export OS_COMPUTE_API_VERSION=2.60\n" \

      send_data(
        out_data,
        type: 'text/plain',
        filename: "openrc-#{@scoped_domain_name}-#{@scoped_project_name}",
        dispostion: 'inline',
        status: :ok
      )
    end

    def download_openrc_ps1
      @token = current_user.token
      @webcli_endpoint = current_user.service_url('webcli')
      @identity_url = current_user.service_url('identity')

      out_data = "$env:OS_AUTH_URL=\"#{@identity_url}\"\r\n" \
        "$env:OS_IDENTITY_API_VERSION=\"3\"\r\n" \
        "$env:OS_PROJECT_NAME=\"#{@scoped_project_name}\"\r\n" \
        "$env:OS_PROJECT_DOMAIN_NAME=\"#{@scoped_domain_name}\"\r\n" \
        "$env:OS_USERNAME=\"#{current_user.name}\"\r\n" \
        "$env:OS_USER_DOMAIN_NAME=\"#{@scoped_domain_name}\"\r\n" \
        "$Password = Read-Host -Prompt \"Please enter your OpenStack Password\" -AsSecureString\r\n" \
        "$env:OS_PASSWORD = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password))\r\n" \
        "$env:OS_REGION_NAME=\"#{current_region}\"\r\n" \
        "$env:OS_COMPUTE_API_VERSION=\"2.60\"\r\n" \

      send_data(
        out_data,
        type: 'text/plain',
        filename: "openrc-#{@scoped_domain_name}-#{@scoped_project_name}.ps1",
        dispostion: 'inline',
        status: :ok
      )
    end

    private

    def get_project
      get_project_id
      @project = services.identity.find_project(
        @project_id, subtree_as_ids: true, parents_as_ids: true
      )
    end

    def get_project_id
      @project_id = params[:id] || params[:project_id]
      entry = FriendlyIdEntry.find_by_class_scope_and_key_or_slug(
        'Project', @scoped_domain_id, @project_id
      )
      @project_id = entry.key if entry
    end

    def check_wizard_status
      # disable wizard for cloud_admin project
      return if %w[ccadmin cloud_admin].include?(@scoped_domain_name)

      # for all services that implements a wizard integration do
      # check the order in /elektra/plugins/identity/spec/controllers/projects_controller_spec.rb
      service_names = %w[masterdata_cockpit networking resource_management].keep_if do |name|
        if name == 'resource_management'
          services.available?(:resources)
        else
          services.available?(name.to_sym)
        end
      end

      # ProjectProfile /elektra/app/models
      project_profile = ProjectProfile.find_or_create_by_project_id(@scoped_project_id)

      # check the status in the project_profiles database
      # if all is done do not show the wizard
      return if project_profile.wizard_finished?(service_names)
      redirect_to plugin('identity').project_wizard_url
    end

    # show the status of all implented wizard steps
    def load_and_update_wizard_status
      @wizard_finished = true
      @project_profile = ProjectProfile.find_or_create_by_project_id(@scoped_project_id)

      # for all services that implements a wizard integration do
      # check the order in /elektra/plugins/identity/spec/controllers/projects_controller_spec.rb
      %w[resource_management masterdata_cockpit networking].each do |service_name|

        if service_name == 'resource_management'
          next unless services.available?(:resources)
        else
          next unless services.available?(service_name.to_sym)
        end

        # set instance variable service available to true
        instance_variable_set("@#{service_name}_service_available", true)

        # check database for finished wizard step otherwise check update_SERVICE_wizard_status()
        # Note: if the wizard done state is set disable this for debugging
        #       or just delete the entry in the database "DELETE from project_profiles WHERE project_id=''"
        next if @project_profile.wizard_finished?(service_name) || @project_profile.wizard_skipped?(service_name)
        # check wizard status for service_name
        @wizard_finished &= begin
          send("update_#{service_name}_wizard_status")
        rescue => _e
          instance_variable_set("@#{service_name}_service_available", false)
          false
        end
      end
    end

    ################### HELPER METHODS #########################
    # this functions are called from load_and_update_wizard_status()
    # RESOURCE MANAGEMENT
    def update_resource_management_wizard_status

      if services.resources.has_project_quotas?(@scoped_domain_id, @scoped_project_id)
        @project_profile.update_wizard_status('resource_management',ProjectProfile::STATUS_DONE)
      else
        @project_profile.update_wizard_status('resource_management', nil)
      end
      @project_profile.wizard_finished?('resource_management')
    end

    # MASTERDATA
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

    # NETWORKING
    def update_networking_wizard_status
      # ensure current user has the network admin role (UNTREATED EDGE CASE: current user isn't admin. Might have to add some stuff for this)
      if current_user.has_role?('admin') && !current_user.has_role?('network_admin')
        network_admin_role = services.identity.grant_project_user_role_by_role_name(@scoped_project_id, current_user.id, 'network_admin')
        # Hack: extend current_user context to add the new assigned role
        current_user.context['roles'] << { 'id' => network_admin_role.id, 'name' => network_admin_role.name }
      end

      # get external networks for this project (using the current user context -> this will retrieve both self-owned and shared networks)
      external_nets = services.networking.networks('router:external' => true)

      # mark wizard done if project has at least one external network. Either shared or owned
      unless external_nets.blank?
        @project_profile.update_wizard_status('networking', ProjectProfile::STATUS_DONE)
      else
        @project_profile.update_wizard_status('networking', nil)
      end

      @project_profile.wizard_finished?('networking')
    end

    def load_project_resource
      begin
        @project_resource = services.resource_management.find_project(@scoped_domain_id, @scoped_project_id)
      rescue
        # do not fail when Limes is down
        @project_resource = nil
      end
    end

  end
end

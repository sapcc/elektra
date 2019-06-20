# frozen_string_literal: true

module MasterdataCockpit
  class ProjectMasterdataController < DashboardController

    before_action :load_project_masterdata, only: [:index, :edit, :show]
    before_action :prepare_params, only: [:create, :update]
    before_action :inheritance
  
    authorization_context 'masterdata_cockpit'
    authorization_required

    def index
      if !@project_masterdata && @masterdata_api_error_code == 404
        # no masterdata was found please define it
        new
        render action: :new
      end
    end

    def new
      @project_masterdata = services.masterdata_cockpit.new_project_masterdata
      inject_projectdata
    end

    def edit
    end

    def update
      unless @project_masterdata.update
        render action: :edit
      end
      # if masterdata edit dialog was opened without modal window
      unless params['modal']
        flash[:notice] = "Masterdata successfully updated."
        redirect_to plugin('masterdata_cockpit').project_masterdata_path
      end
    end

    def create

      # need to cut the length because the masterdata api supports at the moment max 255 chars
      @project_masterdata.description = @active_project.description.truncate(255)

      unless @project_masterdata.save
        render action: :new
      else
        # this is the case if no masterdata was found
        # than we load the new dialog without modal window and need to reload
        # the index page after successful created masterdata
        unless params['modal']
          flash[:notice] = "Masterdata successfully created."
          redirect_to plugin('masterdata_cockpit').project_masterdata_path
        end
        # Note: if modal, then the masterdata was filled within the project wizard
        #       and create.js.haml is loaded to close the modal window
      end
    end

    def show;
    end

    def edit_project
      @project = services.identity.find_project(@scoped_project_id)
    end

    def update_project
      params[:project][:enabled] = params[:project][:enabled] == true ||
                                   params[:project][:enabled] == 'true'

      @project           = service_user.identity.new_project(params[:project])
      @project.id        = @scoped_project_id
      @project.domain_id = @scoped_domain_id

      @project_masterdata = services.masterdata_cockpit.get_project(@scoped_project_id)
      @project_masterdata.project_name = @project.name
      @project_masterdata.description  = @project.description
      @project_masterdata.update

      if @project.save &&
        # has updated project #{@project.name} (#{@project.id})")
        # audit_logger.info(user: current_user, has: "updated",
        #                   project: @project)
        audit_logger.info(current_user, 'has updated', @project)
        # if project edit dialog was opened without modal window
        unless params['modal']
          flash[:notice] = "Project successfully updated."
          redirect_to plugin('masterdata_cockpit').project_masterdata_path
        end

        # special case if project name was updated
        if @scoped_project_name != @project.name
          flash[:notice] = "Project name \"#{@scoped_project_name}\" was successfully renamed to \"#{@project.name}\"."
          @scoped_project_name = @project.name
          @active_project.name = @project.name
          redirect_to plugin('identity').project_path({project_id: @project.id})
        end
      else
        flash.now[:error] = @project.errors.full_messages.to_sentence
        render action: :edit_project
      end
    end

    private

    def load_project_masterdata
      begin
        @project_masterdata = services.masterdata_cockpit.get_project(@scoped_project_id)
        inject_projectdata
        # overide projectdata with current data from identity
      rescue Exception => e
        # do nothing if no masterdata was found
        # the api will only return 404 if no masterdata for the project was found
        @masterdata_api_error_code = e.code
        unless @masterdata_api_error_code == 404
          # all other errors
          flash.now[:error] = "Could not load masterdata. #{e.message}"
        end
      end
    end

    def prepare_params
      @project_masterdata = services.masterdata_cockpit.new_project_masterdata
      # to merge options into .merge(project_id: @scoped_project_id)
      @project_masterdata.attributes = params.fetch(:project_masterdata,{})
      inject_projectdata
    end

    def inheritance
      begin
        if @active_project.parent_id != @scoped_domain_id
          @inheritance = services.masterdata_cockpit.check_inheritance(@scoped_domain_id, @active_project.parent_id)
        else
          @inheritance = services.masterdata_cockpit.check_inheritance(@scoped_domain_id)
        end
      rescue
        flash.now[:error] = "Could not check inheritance."
      end
    end

    def inject_projectdata
      # get the latest values from project to update masterdata
      @project = services.identity.find_project(@scoped_project_id)
      @project_masterdata.project_id   = @project.id
      @project_masterdata.domain_id    = @scoped_domain_id
      @project_masterdata.project_name = @project.name
      @project_masterdata.description  = @project.description
      @project_masterdata.parent_id    = @project.parent_id
    end

  end
end

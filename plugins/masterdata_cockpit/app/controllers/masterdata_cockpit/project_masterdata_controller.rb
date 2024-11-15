# frozen_string_literal: true

module MasterdataCockpit
  class ProjectMasterdataController < DashboardController
    before_action :load_project_masterdata, only: %i[index edit show]
    before_action :prepare_params, only: %i[create update]
    before_action :inheritance

    authorization_context 'masterdata_cockpit'
    authorization_required

    def index
      return unless !@project_masterdata && @masterdata_api_error_code == 404

      # no masterdata was found please define it
      new
      render action: :new
    end

    def new
      @project_masterdata = services.masterdata_cockpit.new_project_masterdata
      inject_projectdata
    end

    def edit
    end

    def update
      render action: :edit unless @project_masterdata.update
      # if masterdata edit dialog was opened without modal window
      return if params['modal']

      flash[:notice] = 'Masterdata successfully updated.'
      redirect_to plugin('masterdata_cockpit').project_masterdata_path
    end

    def create
      # need to cut the length because the masterdata api supports at the moment max 255 chars
      @project_masterdata.description =
        @active_project.description.truncate(255)

      if @project_masterdata.save
        # this is the case if no masterdata was found
        # than we load the new dialog without modal window and need to reload
        # the index page after successful created masterdata
        unless params['modal']
          flash[:notice] = 'Masterdata successfully created.'
          redirect_to plugin('masterdata_cockpit').project_masterdata_path
        end
        # NOTE: if modal, then the masterdata was filled within the project wizard
        #       and create.js.haml is loaded to close the modal window
      else
        render action: :new
      end
    end

    def show
    end

    private

    def load_project_masterdata
      @project_masterdata =
        services.masterdata_cockpit.get_project(@scoped_project_id)
      # special case if api returned with 200 but the data was corrupt
      if @project_masterdata.nil?
        render :no_masterdata_error
        return
      end
      inject_projectdata
    rescue Exception => e
      # do nothing if no masterdata was found
      # the api will only return 404 if no masterdata for the project was found
      @masterdata_api_error_code = e.code
      unless @masterdata_api_error_code == 404
        # all other errors
        flash.now[:error] = "Could not load masterdata. #{e.message}"
      end
    end

    def prepare_params
      @project_masterdata = services.masterdata_cockpit.new_project_masterdata
      # to merge options into .merge(project_id: @scoped_project_id)
      @project_masterdata.attributes = params.fetch(:project_masterdata, {})
      inject_projectdata
    end

    def inheritance
      @inheritance = if @active_project.parent_id != @scoped_domain_id
                       # sub-project level
                       services.masterdata_cockpit.check_inheritance(
                         @scoped_domain_id,
                         @active_project.parent_id
                       )
                     else
                       # domain level
                       services.masterdata_cockpit.check_inheritance(@scoped_domain_id)
                     end
    rescue StandardError
      flash.now[:error] = 'Could not check inheritance.'
    end

    # overide projectdata with current data from identity
    def inject_projectdata
      # get the latest values from project to update masterdata
      @project = services.identity.find_project(@scoped_project_id)
      @project_masterdata.project_id = @project.id
      @project_masterdata.domain_id = @scoped_domain_id
      @project_masterdata.project_name = @project.name
      @project_masterdata.description = @project.description
      @project_masterdata.parent_id = @project.parent_id
    end
  end
end

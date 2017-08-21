# frozen_string_literal: true

module MasterdataCockpit
  class ProjectMasterdataController < DashboardController

    authorization_context 'masterdata_cockpit'
    authorization_required

    def index
      begin
        @project_masterdata = services_ng.masterdata_cockpit.get_project(@scoped_project_id)
      rescue Exception => e
        # do nothing if no masterdata was found
        unless e.message == "Could not find masterdata for this project."
          # all other errors
          flash.now[:error] = "Could not load masterdata. #{e}"
        end
      end
    end
    
    def new
      @project_masterdata = services_ng.masterdata_cockpit.new_project_masterdata
      @project_masterdata.project_id = @scoped_project_id
      @project_masterdata.project_name = @scoped_project_name
    end

    def edit
      @project_masterdata = services_ng.masterdata_cockpit.get_project(@scoped_project_id)
    end

    def update
      @project_masterdata = services_ng.masterdata_cockpit.new_project_masterdata
      
      @project_masterdata.attributes =params.fetch(:project_masterdata,{})

      if @project_masterdata.update
        # HOWTO: needs to change after the api sends a correct repsonse
        @project_masterdata = services_ng.masterdata_cockpit.get_project(@scoped_project_id)
      else
        render action: :edit
      end
    end

    def create
      @project_masterdata = services_ng.masterdata_cockpit.new_project_masterdata
      # to merge options into .merge(project_id: @scoped_project_id)
      @project_masterdata.attributes =params.fetch(:project_masterdata,{})
      
      if @project_masterdata.save
        # HOWTO: needs to change after the api sends a correct repsonse
        @project_masterdata = services_ng.masterdata_cockpit.get_project(@scoped_project_id)
      else
        render action: :new
      end
    end
    
  end
end

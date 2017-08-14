# frozen_string_literal: true

module MasterdataCockpit
  class ProjectMasterdataController < DashboardController

    authorization_context 'masterdata_cockpit'
    authorization_required

    def index
      begin
        @masterdata_found = true
        @project_masterdata = services_ng.masterdata_cockpit.get_project(@scoped_project_id)
      rescue
        @masterdata_found = false
      end
    end
    
    def new
      @project_masterdata = services_ng.masterdata_cockpit.new_project_masterdata
      @project_masterdata.project_id = @scoped_project_id
      @project_masterdata.project_name = @scoped_project_name
    end
    
    def create
      @project_masterdata = services_ng.masterdata_cockpit.new_project_masterdata
      @project_masterdata.description = params[:project_masterdata][:description]

      if @project_masterdata.save
      else
        render action: :new
      end
    end
    
  end
end

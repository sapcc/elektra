# frozen_string_literal: true

module MasterdataCockpit
  class ProjectMasterdataController < DashboardController

    authorization_context 'masterdata_cockpit'
    authorization_required

    def index
      begin
        @masterdata_found = true
        @project_masterdata = services_ng.masterdata_cockpit.get_project(@scoped_project_id)
      rescue Exception => e
        flash.now[:error] = "Could not load masterdata. #{e}"
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
      @project_masterdata.project_id = params[:project_masterdata][:project_id]
      
      # prepare cost_object
      cost_object_inherited if params[:project_masterdata][:cost_object_inherited] == true
      cost_object = { 
        name: params[:project_masterdata][:cost_object_name], 
        type: params[:project_masterdata][:cost_object_type],
        inherited: cost_object_inherited
      }
        
      @project_masterdata.cost_object = cost_object
      
      if @project_masterdata.save
      else
        render action: :new
      end
    end
    
  end
end

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
        # handle no master data found
        if e.message == "Could not find masterdata for this project"
          @masterdata_found = false
        else
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
      
      @project_masterdata.attributes =params.fetch(:project_masterdata,{}).merge(project_id: @scoped_project_id)

      #cost_object_inherited = params[:project_masterdata][:cost_object_inherited] == "true"
      #cost_object = { 
      #  name: params[:project_masterdata][:cost_object_name], 
      #  type: params[:project_masterdata][:cost_object_type],
      #  inherited: cost_object_inherited
      #}
      #@project_masterdata.cost_object = cost_object
      
      if @project_masterdata.update
        # HOWTO: needs to change after the api sends a correct repsonse
        @project_masterdata = services_ng.masterdata_cockpit.get_project(@scoped_project_id)

      else
        render action: :edit
      end
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

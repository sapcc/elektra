# frozen_string_literal: true

module MasterdataCockpit
  class ProjectMasterdataController < DashboardController

    before_filter :load_project_masterdata, only: [:index, :edit, :show]
    before_filter :prepare_params, only: [:create, :update]

    authorization_context 'masterdata_cockpit'
    authorization_required

    def index
    end
    
    def new
      @project_masterdata = services_ng.masterdata_cockpit.new_project_masterdata
    end

    def edit
    end

    def update
      unless @project_masterdata.update
        render action: :edit
      end
    end

    def create
      unless @project_masterdata.save
        render action: :new
      end
    end

    def show;
    end

    private
    
    def load_project_masterdata
      begin
        @project_masterdata = services_ng.masterdata_cockpit.get_project(@scoped_project_id)
      rescue Exception => e
        # do nothing if no masterdata was found
        unless e.message.downcase == "could not find masterdata for this project"
          # all other errors
          flash.now[:error] = "Could not load masterdata. #{e}"
        end
      end
    end
    
    def prepare_params
      @project_masterdata = services_ng.masterdata_cockpit.new_project_masterdata
      # to merge options into .merge(project_id: @scoped_project_id)
      @project_masterdata.attributes =params.fetch(:project_masterdata,{})
    end
    
  end
end

# frozen_string_literal: true

module MasterdataCockpit
  class ProjectMasterdataController < DashboardController

    before_action :load_project_masterdata, only: [:index, :edit, :show]
    before_action :prepare_params, only: [:create, :update]
    before_action :solutions, only: [:create, :update, :new, :edit, :solution_revenue_relevances, :revenue_relevance_cost_object]
    before_action :inheritance

    authorization_context 'masterdata_cockpit'
    authorization_required

    def index
      if !@project_masterdata && @masterdata_api_error_code == 404
        # no masterdata was found please define it
        solutions
        @project_masterdata = services_ng.masterdata_cockpit.new_project_masterdata
        @project_masterdata.description = @active_project.description
        render action: :new
      end
    end
    
    def new
      @project_masterdata = services_ng.masterdata_cockpit.new_project_masterdata
      @project_masterdata.description = @active_project.description
    end

    def edit
    end

    def update
      unless @project_masterdata.update
        render action: :edit
      else
        flash[:notice] = "Masterdata successfully updated."
        redirect_to plugin('masterdata_cockpit').project_masterdata_path
      end
    end

    def create
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
    
    def solution_revenue_relevances
      @solution_name = params[:solution]
      
      @solutions.each do |solution_data|
        if solution_data.name == @solution_name
          # in any case revenue_relevance is uniqe so we can order the date related to revenue_relevance
          @solution_revenue_relevances = solution_data.cost_objects.map {
            |cost_object| 
            [cost_object['revenue_relevance'],{ "name" => cost_object['name'], "type" => cost_object['type']  }]}.to_h
        end
      end
    end
    
    def revenue_relevance_cost_object
      solution_name     = params[:solution]
      revenue_relevance = params[:revenue_relevance]

      @solutions.each do |solution_data|
        if solution_data.name == solution_name
          solution_data.cost_objects.each do |cost_object|
            if cost_object['revenue_relevance'] == revenue_relevance
              @cost_object = { "name" => cost_object['name'], "type" => cost_object['type']  }
            end
          end
        end
      end
    end
    
    private
    
    def load_project_masterdata
      begin
        @project_masterdata = services_ng.masterdata_cockpit.get_project(@scoped_project_id)
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
      @project_masterdata = services_ng.masterdata_cockpit.new_project_masterdata
      # to merge options into .merge(project_id: @scoped_project_id)
      @project_masterdata.attributes =params.fetch(:project_masterdata,{})
    end
    
    def solutions
      begin
        @solutions = services_ng.masterdata_cockpit.get_solutions
      rescue
        flash.now[:error] = "Could not load solutions."
        @solutions = []
      end
    end

    def inheritance
      begin
        @inheritance = services_ng.masterdata_cockpit.check_inheritance(@scoped_domain_id)
      rescue
        flash.now[:error] = "Could not check inheritance."
      end
    end

  end
end

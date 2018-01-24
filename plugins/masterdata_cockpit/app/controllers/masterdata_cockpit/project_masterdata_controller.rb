# frozen_string_literal: true

module MasterdataCockpit
  class ProjectMasterdataController < DashboardController

    before_action :load_project_masterdata, only: [:index, :edit, :show]
    before_action :prepare_params, only: [:create, :update]
    before_action :solutions, only: [:create, :update, :edit, :solution_revenue_relevances, :revenue_relevance_cost_object]
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
      solutions
      @project_masterdata = services.masterdata_cockpit.new_project_masterdata
      inject_projectdata
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
      @project_masterdata.attributes =params.fetch(:project_masterdata,{})
      inject_projectdata
    end
    
    def solutions
      begin
        @solutions = services.masterdata_cockpit.get_solutions
      rescue
        flash.now[:error] = "Could not load solutions."
        @solutions = []
      end
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
      @project_masterdata.project_id   = @scoped_project_id
      @project_masterdata.domain_id    = @scoped_domain_id 
      @project_masterdata.project_name = @scoped_project_name
      # need to cut the length because the masterdata api supports at the moment max 255 chars
      @project_masterdata.description  = @active_project.description.truncate(255)
      @project_masterdata.parent_id    = @active_project.parent_id
    end

  end
end

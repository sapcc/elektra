module AuthenticatedUser
  class InstancesController < AuthenticatedUserController
    
    
    respond_to :html, :json

    def index
      #services.identity
      @active_domain = services.identity.find_domain(@domain_id)
      #render text: 'test' and return

      @user_domain_projects = services.identity.projects.auth_projects

      @active_project = @user_domain_projects.find { |project| project.id == @project_id } if @project_id
      @instances = services.compute.servers if @project_id
      
      @forms_instance = services.compute.forms_instance
    end
    
    def edit
      @forms_instance = services.compute.forms_instance(params[:id])
      respond_to do |format|
        format.html {}
        format.js 
      end
    end
    
    def new
      
    end

    def show
      @instance = services.compute.servers.get(params[:id])
      @flavor = services.compute.flavors.get(@instance.flavor.fetch("id",nil))
      @image = services.compute.images.get(@instance.image.fetch("id",nil))      

      #respond_with nil, responder: ModalResponder
      
      #respond_modal_with @instance
      # if request.xhr?
      #   render action: 'show', layout: 'modal'
      # end
      
      
        
      # respond_to do |format|
      #   format.html {render partial: 'show', locals: {instance: @instance, flavor: @flavor}}
      #   format.js { render partial: 'show', locals: {instance: @instance, flavor: @flavor}}
      # end
      
      
    end
  end

end

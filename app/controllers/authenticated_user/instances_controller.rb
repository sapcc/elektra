module AuthenticatedUser
  class InstancesController < AuthenticatedUserController

    def index
      #services.identity
      @active_domain = services.identity.find_domain(@domain_id)
      #render text: 'test' and return

      @user_domain_projects = services.identity.projects.auth_projects

      @active_project = @user_domain_projects.find { |project| project.id == @project_id } if @project_id
      @instances = services.compute.servers if @project_id
    end
    
    def show
      @instance = services.compute.servers.get(params[:id])
      @flavor = services.compute.flavors.get(@instance.flavor.fetch("id",nil))
      @image = services.compute.images.get(@instance.image.fetch("id",nil))      
    end
    
    def new
      @forms_instance = services.compute.forms_instance
    end
    
    def create
      
    end
    
    def edit
      @forms_instance = services.compute.forms_instance(params[:id])
      respond_to do |format|
        format.html {}
        format.js 
      end
    end
    
    def update
      
    end
    
    def destroy
      @forms_instance = services.compute.forms_instance(params[:id])
      
      if @forms_instance.destroy
        flash[:notice] = "Instance deleted."
      else
        flash[:notice] = "Could not delete instance."
      end
      redirect_to instances_url(domain_id:@domain_id,project_id:@project_id)
    end
  end

end

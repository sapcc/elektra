module AuthenticatedUser
  class InstancesController < AuthenticatedUserController

    def index
      #services.identity
      @active_domain = services.identity.find_domain(@domain_id)
      #render text: 'test' and return

      @user_domain_projects = services.identity.projects.auth_projects

      @active_project = @user_domain_projects.find { |project| project.id == @project_id } if @project_id
      @instances = services.compute.servers if @project_id
      
      p @instances
    end
    
    def show
      @instance = services.compute.servers.get(params[:id])
      @flavor = services.compute.flavors.get(@instance.flavor.fetch("id",nil))
      @image = services.compute.images.get(@instance.image.fetch("id",nil))      
    end
    
    def new
      @forms_instance = services.compute.forms_instance
      @flavors = services.compute.flavors
      @images = services.image.images
      
      @forms_instance.flavor=@flavors.first.id
      @forms_instance.image=@images.first.id
    end
    
    def create
      @forms_instance = services.compute.forms_instance(params[:id])    
      @forms_instance.attributes=params[:forms_instance]
      
      if @forms_instance.save
        flash[:notice] = "Instance successfully created."
        redirect_to instances_path(domain_id:@domain_id, project_id:@project_id)
      else
        @flavors = services.compute.flavors
        @images = services.image.images
        render action: :new
      end
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

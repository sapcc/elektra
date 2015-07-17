class AuthenticatedUser::ProjectsController < AuthenticatedUserController

  before_filter only: [:index, :create, :update] do
    @active_domain = services.identity.find_domain(@domain_id)
    @user_domain_projects = services.identity.projects(@active_domain.id)
  end
  
  def credentials
    @user_credentials = services.identity.credentials 
    @forms_credential = services.identity.forms_credential
    render json: @user_credentials
  end

  def index
    
  end

  def show
    @forms_project = services.identity.forms_project(params[:id])
  end
  
  def new
    @forms_project = services.identity.forms_project
  end

  def create
    @forms_project = services.identity.forms_project
    @forms_project.attributes = params.fetch(:forms_project,{}).merge(domain_id: @domain_id)

    if @forms_project.save
      services.identity.grant_project_role(@forms_project.model,'admin')
      flash[:notice] = "Project #{@forms_project.name} successfully created."
      redirect_to projects_path(domain_id: @domain_id)
    else
      flash[:error] = @forms_project.errors.full_messages.to_sentence
      render action: :new
    end
    
  end
  
  def edit
    @forms_project = services.identity.forms_project(params[:id])
  end
  
  def update
    @forms_project = services.identity.forms_project(params[:id])
    @forms_project.attributes = params[:forms_project]
    
    if @forms_project.save
      flash[:notice] = "Project #{@forms_project.name} successfully updated."
      redirect_to projects_path(domain_id: @domain_id)
    else
      flash[:error] = @forms_project.errors.full_messages.join(', ')
      render action: :edit
    end
  end
  
  def destroy
    forms_project = services.identity.forms_project(params[:id])
        
    if forms_project.destroy
      flash[:notice] = "Project successfully deleted."
    else
      flash[:error] = forms_project.errors.full_messages.to_sentence #"Something when wrong when trying to delete the project"
    end

    redirect_to projects_path(@domain_id)
  end

end

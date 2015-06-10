class AuthenticatedUser::ProjectsController < AuthenticatedUserController

  def index
    @active_domain = services.identity.user_domain(@domain_id)
    @user_domain_projects = services.identity.user_domain_projects(@active_domain.id)
    @forms_project = services.identity.forms_project
  end

  def show
    @forms_project = services.identity.forms_project(params[:id])
  end

  def create
    @forms_project = services.identity.forms_project
    @forms_project.attributes = params.fetch(:forms_project,{}).merge(domain_id: @domain_id)

    if @forms_project.save
      services.identity.grant_project_role(@forms_project.model,'admin')
    else
      flash[:error] = @forms_project.errors.full_messages.to_sentence
    end
    redirect_to :back
  end
  
  def update
    @forms_project = services.identity.forms_project(params[:id])
    @forms_project.attributes = params[:forms_project]
    
    unless @forms_project.save
      flash[:error] = @forms_project.errors.full_messages.join(', ')
    end
    redirect_to :back
  end
  
  def destroy
    forms_project = services.identity.forms_project(params[:id])
        
    if forms_project.destroy
      flash[:notice] = "Project successfully deleted"
    else
      flash[:error] = forms_project.errors.full_messages #"Something when wrong when trying to delete the project"
    end

    redirect_to projects_path(@domain_id)
  end

end

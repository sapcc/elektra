class AuthenticatedUser::ProjectsController < AuthenticatedUserController

  before_filter :load_project,  except: [:index, :create, :new]

  def index
    @active_domain = services.identity.find_domain(@domain_id)
    @projects = services.identity.projects(@active_domain.id)
  end

  def show
    @current_project = services.identity.projects.find_by_id(@project.key, :subtree_as_list)
    @instances = services.compute.servers.all(tenant_id: @current_project.id)
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
      redirect_to projects_path(project_fid: nil)
    else
      flash[:error] = @forms_project.errors.full_messages.to_sentence
      render action: :new
    end

  end

  def edit
    @forms_project = services.identity.forms_project(@project.key)
  end

  def update
    @forms_project = services.identity.forms_project(@project.key)
    @forms_project.attributes = params[:forms_project]

    if @forms_project.save
      flash[:notice] = "Project #{@forms_project.name} successfully updated."
      redirect_to projects_path(project_fid: nil)
    else
      flash[:error] = @forms_project.errors.full_messages.join(', ')
      render action: :edit
    end
  end
  
  def destroy
    forms_project = services.identity.forms_project(@project.key)
        
    if forms_project.destroy
      flash[:notice] = "Project successfully deleted."
    else
      flash[:error] = forms_project.errors.full_messages.to_sentence #"Something when wrong when trying to delete the project"
    end

    redirect_to projects_path(@domain_fid)
  end

  private

  def load_project
    @domain = ::Domain.friendly_find_or_create @region, @domain_id
    @project = ::Project.friendly_find_or_create @region, @domain, params[:id]
  end

end

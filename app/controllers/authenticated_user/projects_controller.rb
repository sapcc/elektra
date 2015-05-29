class AuthenticatedUser::ProjectsController < AuthenticatedUserController

  def index
    @active_domain = services.identity.user_domain(@domain_id)
    @user_domain_projects = services.identity.user_domain_projects(@active_domain.id)
  end

  def show
    @project = services.identity.user_project(params[:id])
  end

  def create
    project = Forms::Project.new(@domain_id, services.identity, params.merge({user_id: current_user.id}))

    if project.save
      redirect_to :back
    else
      flash[:error] = project.errors
    end

    redirect_to :back
  end

  def destroy
    project = Forms::Project.new(@domain_id, services.identity, params)

    if project.destroy
      flash[:notice] = "Project successfully deleted"
    else
      flash[:error] = "Something when wrong when trying to delete the project"
    end

    redirect_to projects_path(@domain_id)
  end

end

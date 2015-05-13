module AuthenticatedUser
  class InstancesController < AuthenticatedUserController
    
    def index
      @active_domain = services.identity.user_domain(@domain_id)

      @user_domain_projects = services.identity.user_domain_projects(@active_domain.id)

      @active_project = @user_domain_projects.find { |project| project.id == @project_id } if @project_id
      @instances = true if @project_id
    end
    
  end
  
end

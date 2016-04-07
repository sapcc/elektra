module Identity
  class DomainsController < ::DashboardController
    rescue_from "MonsoonOpenstackAuth::Authentication::NotAuthorized", with: :not_member_error
    authorization_required additional_policy_params: {domain_id: proc {@scoped_domain_id}}

    def show
      @user_domain_projects_tree = services.identity.auth_projects_tree
      @root_projects = @user_domain_projects.reject{ |project| !project.parent.blank? }
    end

    def index
      @domains = services.identity.domains
    end

    def not_member_error
      @error_title = "No domain member"
      @error_message = "You are not a member of the domain #{@scoped_domain_name}."
      render template: '/application/error'
    end
  end
end

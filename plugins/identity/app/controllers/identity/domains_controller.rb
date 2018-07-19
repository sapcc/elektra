# frozen_string_literal: true

module Identity
  # This class implements domain actions
  class DomainsController < ::DashboardController
    authorization_required additional_policy_params: {
      domain_id: proc { @scoped_domain_id }
    }, except: [:show]

    def show
      @user_domain_projects_tree = services.identity.auth_projects_tree(
        @user_domain_projects
      )
      @root_projects = @user_domain_projects.select { |pr| pr.parent.blank? }
      @domain = service_user.identity.find_domain(@scoped_domain_id)
    end

    def index
      @domains = services.identity.domains
    end
  end
end

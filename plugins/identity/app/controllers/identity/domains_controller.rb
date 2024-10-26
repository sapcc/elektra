# frozen_string_literal: true

module Identity
  # This class implements domain actions
  class DomainsController < ::DashboardController
    before_action :load_domain, only: %i[show auth_projects]

    authorization_required additional_policy_params: { domain_id: proc { @domain&.id } },
                           except: %i[show auth_projects]

    def show; end

    def index
      @domains = services.identity.auth_domains
    end

    # to render the projects menu on domain and project level
    # this function is called anytime elektra view es rerendered
    def auth_projects
      projects =
        services.identity.auth_projects(@domain.id).sort_by(&:name)
      render json: { auth_projects: projects }
    end

    protected

    def load_domain
      domain_id = @scoped_domain_id
      @domain = services.identity.find_domain(domain_id)
      return unless @domain.nil?

      domains = services.identity.auth_domains
      @domain = domains.find { |d| d.id == domain_id || d.name == domain_id }
    end
  end
end

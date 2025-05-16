# frozen_string_literal: true

module Identity
  # This class implements domain actions
  class DomainsController < ::DashboardController
    authorization_required additional_policy_params: {
                             domain_id: proc { @scoped_domain_id },
                           },
                           except: %i[show auth_projects]

    def show
      @domain = service_user.identity.find_domain(@scoped_domain_id)
    end

    def index
      @domains = services.identity.domains
    end

    # to render the projects menu on domain and project level
    # this function is called anytime elektra view es rerendered
    def auth_projects
      projects =
        services.identity.auth_projects(@scoped_domain_id).sort_by(&:name)

      updated_projects = projects.map do |project|
        project.domain_id = @scoped_domain_fid
        project
      end
      
      render json: { auth_projects: updated_projects }
    end

    def api_endpoints
      @token = current_user.token
      @webcli_endpoint = current_user.service_url('webcli')
      @identity_url = current_user.service_url('identity')
    end

    def download_openrc_ps1
    end

    def download_openrc
    end

  end
end

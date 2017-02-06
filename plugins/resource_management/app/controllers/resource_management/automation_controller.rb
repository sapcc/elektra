require_dependency "resource_management/application_controller"

module ResourceManagement
  class AutomationController < ::ResourceManagement::ApplicationController

    # requires cloud_admin permission to use (intended for use with a privileged technical user)
    authorization_required

    # bypass Terms-of-Use check for technical users
    def check_terms_of_use
      return
    end

    def sync_domain
      domain_name = params.require(:domain_name)
      domain = services.identity.domains(name: domain_name).first
      if domain.nil?
        render plain: "ERROR: cannot find domain \"#{domain_name}\"", status: :bad_request
        return
      end

      # sync quota/usage data for domain and projects in this domain
      begin
        services.resource_management.sync_domain(
          domain.id, domain_name,
          timeout_secs: 50,   # abort after 50 seconds to avoid HTTP connection timeout (~1 minute)
          refresh_secs: 1800, # do not try to update data that's newer than 30 minutes ago
        )
      rescue Interrupt
        # not yet done - restart the sync by redirecting the client to the same
        # URL (this might look like an infinite redirect, so the client should
        # be prepared to handle a long redirection chain,
        # e.g. `curl -L --max-redirs -1`)
        redirect_to plugin('resource_management').automation_sync_domain_url(
          project_id:  @scoped_project_name,
          domain_id:   @scoped_domain_name,
          domain_name: domain_name,
        )
        return
      end

      # sync finished - tell the client to sleep until the first data becomes stale again
      min_updated_at = ResourceManagement::Resource.where(domain_id: domain.id).minimum(:updated_at)
      sleep_seconds = (((min_updated_at + 1800.seconds) - Time.now) / 1.second).round
      render plain: "please sleep for #{sleep_seconds} seconds", status: :ok
    end

    def dump_data
      # TODO
    end

    private

    def service
      cfg = Rails.application.config
      @service ||= ::ServiceLayer::ResourceManagementService.new(
        cfg.keystone_endpoint,
        [cfg.default_region].flatten.first,
      )
    end

  end
end

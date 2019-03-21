# frozen_string_literal: true

module Resources
  class RequestController < DashboardController

    before_action :check_authorization

    # TODO: This part of plugins/resources bridges back into the "old" world of
    # plugins/resource_management by creating inquiries in the same way that
    # the old plugin does.

    def project
      puts ("XXXXXXXXXXX")
      puts params.inspect

      raise StandardError, 'TODO implement'
    end

    def domain
      # TODO
    end

    private

    def check_authorization
      # NOTE: If this looks odd to you, have a look at the big comment in the
      # ApplicationController.
      auth_params = { project_id: @scoped_project_id, domain_id:  @scoped_domain_id }
      scope = @scoped_project_id ? 'domain' : 'project'
      enforce_permissions("::#{scope}:edit", { selected: auth_params })
    end

  end
end

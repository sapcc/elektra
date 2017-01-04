module SharedFilesystemStorage
  class ApplicationController < ::DashboardController
    # add project_id to default policy params (needed by policy rules).
    before_filter do
      @policy_default_params ||= { }
      @policy_default_params[:project_id] = @scoped_project_id
    end

    # set policy context
    authorization_context 'shared_filesystem_storage'
    # enforce permission checks. This will automatically investigate the rule name.
    authorization_required

    def show
      @permissions = {
        shares: {
          list: current_user.is_allowed?("shared_filesystem_storage:share_list"),
          create: current_user.is_allowed?("shared_filesystem_storage:share_create")
        },
        snapshots: {
          list: current_user.is_allowed?("shared_filesystem_storage:snapshot_list"),
          create: current_user.is_allowed?("shared_filesystem_storage:snapshot_create")
        },
        share_networks: {
          list: current_user.is_allowed?("shared_filesystem_storage:share_network_list"),
          create: current_user.is_allowed?("shared_filesystem_storage:share_network_create")
        }
      }
    end
  end
end

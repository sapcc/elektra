module SharedFilesystemStorage
  class ApplicationController < ::DashboardController
    def index
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
          list: current_user.is_allowed?("shared_filesystem_storage:shared_network_list"),
          create: current_user.is_allowed?("shared_filesystem_storage:shared_network_create")
        }
      }
    end
  end
end
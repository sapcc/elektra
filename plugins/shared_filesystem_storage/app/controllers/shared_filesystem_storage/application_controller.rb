# frozen_string_literal: true

module SharedFilesystemStorage
  # Application controller for SharedFilesystemStorage
  class ApplicationController < ::DashboardController
    # set policy context
    authorization_context 'shared_filesystem_storage'
    # enforce permission checks. This will automatically
    # investigate the rule name.
    authorization_required

    def show
      @permissions = {
        shares: {
          list: current_user.is_allowed?('shared_filesystem_storage:share_list'),
          create: current_user.is_allowed?('shared_filesystem_storage:share_create')
        },
        snapshots: {
          list: current_user.is_allowed?('shared_filesystem_storage:snapshot_list'),
          create: current_user.is_allowed?('shared_filesystem_storage:snapshot_create')
        },
        share_networks: {
          list: current_user.is_allowed?('shared_filesystem_storage:share_network_list'),
          create: current_user.is_allowed?('shared_filesystem_storage:share_network_create')
        },
        security_services: {
          list: current_user.is_allowed?('shared_filesystem_storage:security_service_list'),
          create: current_user.is_allowed?('shared_filesystem_storage:security_service_create')
        }
      }
    end
  end
end

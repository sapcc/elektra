# frozen_string_literal: true

module SharedFilesystemStorage
  # Application controller for SharedFilesystemStorage
  class ApplicationController < ::DashboardController
    # set policy context
    authorization_context "shared_filesystem_storage"
    # enforce permission checks. This will automatically
    # investigate the rule name.
    authorization_required

    def show
    end
  end
end

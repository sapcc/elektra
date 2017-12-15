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
      render inline: '<div id="shared_filesystem_storage_react_container"/>',
             layout: true,
             content_type: 'text/html'
    end
  end
end

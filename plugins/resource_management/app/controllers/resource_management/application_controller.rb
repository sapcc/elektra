module ResourceManagement
  class ApplicationController < ::DashboardController
    # This is the base class of all controllers in this plugin. Only put code in here that is shared across controllers.
    authorization_context "resource_management"
  end
end

module Swift
  class ApplicationController < DashboardController
    # This is the base class of all controllers in this plugin. Only put code in here that is shared across controllers.
    authorization_context 'swift'
  end
end

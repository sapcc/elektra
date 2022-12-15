# frozen_string_literal: true

module MasterdataCockpit
  class ApplicationController < DashboardController
    # This is the base class of all controllers in this plugin. Only put code in here that is shared across controllers.
    authorization_context "masterdata_cockpit"
  end
end

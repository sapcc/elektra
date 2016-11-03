module CostControl
  class ApplicationController < DashboardController
    # This is the base class of all controllers in this plugin. Only put code in here that is shared across controllers.
    authorization_context 'cost_control'
  end

  protected

  def release_state
    "experimental"
  end
end

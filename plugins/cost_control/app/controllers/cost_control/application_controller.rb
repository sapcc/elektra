require 'fog/billing/openstack/models/error'

module CostControl
  class ApplicationController < DashboardController
    # This is the base class of all controllers in this plugin. Only put code in here that is shared across controllers.
    authorization_context 'cost_control'

    rescue_and_render_exception_page [
                                         {
                                             "Fog::Billing::ApiError" => {
                                                 header_title: "Monsoon3 Cost Control",
                                                 title: "No billing data available.",
                                                 detail:      :detail
                                             }
                                         }
                                     ]
  end

  protected

  def release_state
    "experimental"
  end
end

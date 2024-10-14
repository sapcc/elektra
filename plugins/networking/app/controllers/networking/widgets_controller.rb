module Networking
  # Implements Network actions
  class WidgetsController < DashboardController
    # set policy context
    authorization_context "networking"
    # enforce permission checks. This will automatically
    # investigate the rule name.
    authorization_required only: %i[ports bgp_vpns]

    def bgp_vpns
    end

    def security_groups
    end

    def ports
    end
  end
end

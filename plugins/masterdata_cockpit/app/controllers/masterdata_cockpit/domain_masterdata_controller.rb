# frozen_string_literal: true

module MasterdataCockpit
  class DomainMasterdataController < DashboardController

    authorization_context 'masterdata_cockpit'
    authorization_required
    
    def index
    end
  end
end

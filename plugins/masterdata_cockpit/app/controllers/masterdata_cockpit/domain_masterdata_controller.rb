# frozen_string_literal: true

module MasterdataCockpit
  class DomainMasterdataController < DashboardController

    authorization_context 'masterdata_cockpit'
    authorization_required
    
    def index
      begin
        @domain_masterdata = services_ng.masterdata_cockpit.get_domain(@scoped_domain_id)
      rescue Exception => e
        # handle no masterdata found
        unless e.message == "Could not find masterdata for this domain"
          # all other errors
          flash.now[:error] = "Could not load masterdata. #{e}"
        end
      end
    end
  end
end

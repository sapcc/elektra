# frozen_string_literal: true

module MasterdataCockpit
  class DomainMasterdataController < DashboardController

    authorization_context 'masterdata_cockpit'
    authorization_required
    
    def index
      begin
        @domain_masterdata = services_ng.masterdata_cockpit.get_domain(@scoped_domain_id)
      rescue Exception => e
        # do nothing if no masterdata was found
        unless e.message.downcase == "could not find masterdata for this domain."
          # all other errors
          flash.now[:error] = "Could not load masterdata. #{e}"
        end
      end
    end

    def new
      @domain_masterdata = services_ng.masterdata_cockpit.new_domain_masterdata
      @domain_masterdata.domain_id = @scoped_domain_id
      @domain_masterdata.domain_name = @scoped_domain_name
    end

    def create
      @domain_masterdata = services_ng.masterdata_cockpit.new_domain_masterdata
      # to merge options into .merge(domain_id: @scoped_domain_id)
      @domain_masterdata.attributes =params.fetch(:domain_masterdata,{})
      
      unless @domain_masterdata.save
        render action: :new
      end
    end
  end
end

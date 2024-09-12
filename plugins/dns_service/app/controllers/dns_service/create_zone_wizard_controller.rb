module DnsService
  class CreateZoneWizardController < ::DashboardController
    before_action :load_inquiry
    include CreateZonesHelper

    def new
      @zone_request = ::DnsService::ZoneRequest.new(nil)
      return if @inquiry.nil?
      payload = @inquiry.payload
      @zone_request.attributes = payload
      @pool = load_pool(@zone_request.domain_pool)
    end

    def create
      @zone_request = ::DnsService::ZoneRequest.new(nil, params[:zone_request])
      @pool = load_pool(@zone_request.domain_pool)
      @zone = create_zone(@zone_request.zone_name,@zone_request.attributes,@inquiry.domain_id, @inquiry.project_id)

      if @zone.errors.empty?
        if @inquiry
            services.inquiry.set_inquiry_state(
              @inquiry.id,
              :approved,
              "Domain #{@zone.name} approved and created by #{current_user.full_name}",
              current_user,
            )
          end
        render action: :create
      else
        @zone.errors.each { |e| @zone_request.errors.add(e.attribute, e.message) }
        render action: :new
      end
    end

    protected

    def load_inquiry
      return if params[:inquiry_id].blank?
      @inquiry = services.inquiry.get_inquiry(params[:inquiry_id])
    end

    def load_pool(pool_id)
      cloud_admin.dns_service.find_pool(pool_id)
    end
  end
end

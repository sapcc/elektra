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

      if @inquiry
        scraped_at =
          begin
            cloud_admin
              .resource_management
              .find_project(
                @inquiry.domain_id,
                @inquiry.project_id,
                service: "dns",
                resource: "zones",
              )
              .services
              .first
              .scraped_at
          rescue StandardError
            0
          end

        # sync if last sync was more than 5 minutes ago
        if (Time.now.to_i - scraped_at.to_i) > 300
          Thread.new do
            cloud_admin.resource_management.sync_project_asynchronously(
              @inquiry.domain_id,
              @inquiry.project_id,
            )
          end
        end
      end
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

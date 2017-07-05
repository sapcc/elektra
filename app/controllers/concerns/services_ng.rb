# frozen_string_literal: true

# this module is included in controllers.
# the controller should respond_to current_user (monsoon-openstack-auth gem)
module ServicesNg
  def self.included(base)
    base.send :helper_method, :services, :services_ng, :current_region
  end

  # try to find a region based on catalog and default region
  def current_region
    @services_current_region ||=
      ::Core.region_from_auth_url ||
      ::Core.locate_region(service_user, Rails.configuration.default_region)
  end

  def services_ng
    return unless current_user
    api_client = Core::Api::ClientManager
                 .user_api_client(current_user)
    @services_ng ||= Core::ServiceLayerNg::ServicesManager.new(api_client)
  end

  def service_user_ng
    return @service_user_ng if @service_user_ng

    friendly_id = FriendlyIdEntry.find_by_class_scope_and_key_or_slug(
      'Domain', nil, params[:domain_id]
    )

    scope_domain = (friendly_id && friendly_id.key) ||
                   params[:domain_id] || Rails.configuration.default_domain

    @service_user_ng ||= Core::ServiceLayerNg::ServicesManager.new(
      Core::Api::ClientManager
      .service_user_api_client(scope_domain)
    )
  end

  def cloud_admin_ng
    @cloud_admin_ng ||= Core::ServiceLayerNg::ServicesManager.new(
      Core::Api::ClientManager.cloud_admin_api_client
    )
  end
end

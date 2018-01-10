# frozen_string_literal: true

# this module is included in controllers.
# the controller should respond_to current_user (monsoon-openstack-auth gem)
module ServicesNg
  def self.included(base)
    base.send :helper_method, :services_ng, :service_user,
              :cloud_admin, :current_region
  end

  # try to find a region based on catalog and default region
  def current_region
    @services_current_region ||= Rails.configuration.default_region
  end

  def services_ng
    return @services_ng if @services_ng && @token_expires_at == current_user.token_expires_at
    api_client = begin
                   Core::Api::ClientManager.user_api_client(current_user)
                 rescue => _e
                   nil
                 end
    @token_expires_at = current_user.token_expires_at
    @services_ng = Core::ServiceLayerNg::ServicesManager.new(api_client)
  end

  def service_user
    return @service_user if @service_user_loaded

    friendly_id = FriendlyIdEntry.find_by_class_scope_and_key_or_slug(
      'Domain', nil, params[:domain_id]
    )

    scope_domain = (friendly_id && friendly_id.key) ||
                   params[:domain_id] || Rails.configuration.default_domain

    @service_user_loaded = true
    @service_user ||= Core::ServiceLayerNg::ServicesManager.new(
      Core::Api::ClientManager.service_user_api_client(scope_domain)
    )
  end

  def cloud_admin
    @cloud_admin ||= Core::ServiceLayerNg::ServicesManager.new(
      Core::Api::ClientManager.cloud_admin_api_client
    )
  end
end

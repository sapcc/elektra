# frozen_string_literal: true

# this module is included in controllers.
# the controller should respond_to current_user (monsoon-openstack-auth gem)
module Services
  def self.included(base)
    base.send :helper_method, :services, :service_user,
              :cloud_admin, :current_region
  end

  # try to find a region based on catalog and default region
  def current_region
    @services_current_region ||= Rails.configuration.default_region
  end

  def services
    if current_user
      token_expires_at = current_user.token_expires_at
      token = current_user.token
    end

    # re-initialize services if token re-newed or expired
    if @services && @token_expires_at == token_expires_at && @services_token == token
      return @services
    end

    api_client = begin
                   Core::ApiClientManager.user_api_client(current_user)
                 rescue StandardError
                   nil
                 end
    # cache token infos             
    @token_expires_at = token_expires_at
    @services_token = token
    @services = Core::ServiceLayer::ServicesManager.new(api_client)
  end

  def service_user
    return @service_user if @service_user_loaded

    friendly_id = FriendlyIdEntry.find_by_class_scope_and_key_or_slug(
      'Domain', nil, params[:domain_id]
    )

    scope_domain = (friendly_id && friendly_id.key) ||
                   params[:domain_id] || Rails.configuration.default_domain

    @service_user_loaded = true
    @service_user ||= Core::ServiceLayer::ServicesManager.new(
      Core::ApiClientManager.service_user_api_client(scope_domain)
    )
  end

  def cloud_admin
    @cloud_admin ||= Core::ServiceLayer::ServicesManager.new(
      Core::ApiClientManager.cloud_admin_api_client
    )
  end
end

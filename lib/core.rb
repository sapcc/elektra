# frozen_string_literal: true

require_relative "core/data_type"
require_relative "core/formatter"
require_relative "core/plugins_manager"
require_relative "core/api_client_manager"
require_relative "core/service_layer"
require_relative "core/audit_logger"
require_relative "core/error"
require_relative "core/paginatable"
require_relative "core/static_config"

# Core module contains all essential functionalities
module Core
  def self.locate_region(
    auth_user,
    default_region = Rails.configuration.default_region
  )
    unless default_region
      return auth_user.nil? ? nil : auth_user.default_services_region
    end

    default_regions = default_region
    # make default_region to an array
    default_regions = [default_regions] unless default_regions.is_a?(Array)
    # compare default regions with regions from catalog
    regions =
      if auth_user.nil?
        default_regions
      else
        (default_regions & auth_user.available_services_regions)
      end

    return regions.first if regions && regions.length.positive?

    # return default region from configuration or from catalog or nil
    if auth_user.nil? || auth_user.default_services_region.nil?
      default_regions.first
    else
      auth_user.default_services_region
    end
  end

  def self.keystone_auth_endpoint(endpoint_url = nil)
    endpoint =
      begin
        endpoint_url || Rails.configuration.keystone_endpoint
      rescue StandardError
        ""
      end

    unless endpoint && endpoint.include?("auth/tokens")
      endpoint += "/" if endpoint.last != "/"
      endpoint += "auth/tokens"
    end
    endpoint
  end
end

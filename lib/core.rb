require_relative 'core/data_type'
require_relative 'core/formatter'
require_relative 'core/plugins_manager'
require_relative 'core/service_layer'
require_relative 'core/service_user'
require_relative 'core/audit_logger'
require_relative 'core/errors'
require_relative 'core/paginatable'
require_relative 'core/strip_attributes'

module Core
  def self.locate_region(auth_user,default_region=Rails.configuration.default_region)
    if default_region.nil?
      # default region is nil -> return default region from catalog or nil
      return auth_user.nil? ? nil : auth_user.default_services_region
    else
      default_regions = default_region
      # make default_region to an array
      default_regions = [default_regions] unless default_regions.is_a?(Array)
      # compare default regions with regions from catalog
      regions = auth_user.nil? ? default_regions : (default_regions & auth_user.available_services_regions)

      if regions and regions.length>0
        # regions match found -> return first
        return regions.first
      else
        # return default region from configuration or from catalog or nil
        return (auth_user.nil? or auth_user.default_services_region.nil?) ? default_regions.first : auth_user.default_services_region
      end
    end
  end

  def self.keystone_auth_endpoint(endpoint_url=nil)
    endpoint = endpoint_url || Rails.configuration.keystone_endpoint rescue ''

    unless endpoint and endpoint.include?('auth/tokens')
      endpoint += '/' if endpoint.last!='/'
      endpoint += 'auth/tokens'
    end
    endpoint
  end
end

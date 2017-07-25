require "resource_management/engine"
# use misty with our limes-resources extension
require 'misty/openstack/limes'
# load resource management related config
require_relative "resource_management/package_config"
require_relative "resource_management/resource_config"
require_relative "resource_management/service_config"

module ResourceManagement
end

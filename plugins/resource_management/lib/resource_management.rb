require "resource_management/engine"
# use misty with our converged cloud extension
require 'misty/openstack/cc'
# load resource management related config
require_relative "resource_management/package"
require_relative "resource_management/resource_config"
require_relative "resource_management/service_config"

module ResourceManagement
end

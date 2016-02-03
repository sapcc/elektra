require "resource_management/resource_config"
require "resource_management/service_config"

module ResourceManagement
  class Resource < ActiveRecord::Base
    validates_presence_of :domain_id, :service, :name

    def config
      sn = service.to_sym
      rn = name.to_sym
      ResourceManagement::ResourceConfig.all.find { |r| r.service_name == sn && r.name == rn }
    end

    def data_type
      config.data_type
    end

  end
end

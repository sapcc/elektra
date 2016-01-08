module ResourceManagement
  class Capacity < ActiveRecord::Base
    validates_presence_of :service, :resource, :value

    def attributes
      # get attributes for this resource
      resource_attrs = ResourceManagement::Resource::KNOWN_RESOURCES.find { |r| r[:service] == service.to_sym and r[:name] == resource.to_sym }
      # merge attributes for the resource's services
      service_attrs = ResourceManagement::Resource::KNOWN_SERVICES.find { |s| s[:service] == service.to_sym }
      return (resource_attrs || {}).merge(service_attrs || {})
    end

    def data_type
      ResourceManagement::DataType.new(attributes[:data_type] || :number)
    end

  end
end

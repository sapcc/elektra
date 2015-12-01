module ResourceManagement
  module ApplicationHelper

    include ResourceBarHelper

    def list_areas_with_enabled_services
      services = ResourceManagement::Resource::KNOWN_SERVICES
      services.select { |srv| srv[:enabled] }.map { |srv| srv[:area] }.uniq
    end

  end
end

# frozen_string_literal: true

module Dashboard
  class DashboardService
    def self_registration_domain?(domain_name)
      if domain_name && Settings && Settings.self_registration_domains &&
           Settings.self_registration_domains.include?(domain_name)
        return true
      end
      false
    end
  end
end

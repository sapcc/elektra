module Dashboard
  class OnboardingService


    def self_registration_domain?(domain_name)
      if domain_name and
          Settings and
          Settings.self_registration_domains and
          Settings.self_registration_domains.include?(domain_name)
        return true
      end
      return false
    end


  end
end
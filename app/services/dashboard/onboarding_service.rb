module Dashboard
  class OnboardingService
    
    def initialize(service_user)
      @service_user = service_user
    end
      
    def new_user?(current_user)
      @service_user.role_assignments("user.id"=>current_user.id,"scope.domain.id"=>current_user.domain_id, effective: true).empty?      
    end

    def register_user(current_user)
      # current user domain exists and it is allowed for self registration
      if current_user.user_domain_name and 
        Settings and 
        Settings.self_registration_domains and 
        Settings.self_registration_domains.include?(current_user.user_domain_name)
        
        group_name = "CC_#{current_user.user_domain_name.upcase}_DOMAIN_MEMBERS"
        @service_user.add_user_to_group(current_user.id,group_name)
      end
    end
  end
end
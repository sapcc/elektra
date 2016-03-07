module Dashboard
  class OnboardingService
    
    def initialize(service_user)
      @service_user = service_user
    end
      
    def new_user?(current_user)
      @service_user.role_assignments("user.id"=>current_user.id).empty?      
    end

    def register_user(current_user)
      @service_user.grant_user_domain_member_role(current_user.id,'member')
    end
  end
end
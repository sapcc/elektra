module Admin
  class OnboardingService
      
    def self.new_user?(current_user)
      Admin::IdentityService.role_assignments("user.id"=>current_user.id).empty?      
    end

    def self.register_user(current_user)
      Admin::IdentityService.create_user_domain_role(current_user,'member')
    end
  end
end
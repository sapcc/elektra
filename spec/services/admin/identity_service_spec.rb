require 'spec_helper'

RSpec.describe Admin::IdentityService do
  
  describe 'create_user_domain_role' do
    before :each do
      @current_user = double('current_user', user_domain_id: 'd1', id: 1) 
      @member_role = Identity::Role.new(nil,{name:'member', id: 2})      
    end
    
    it 'should grant a domain role to user' do
      admin_identity = double("admin_identity_service")
      allow(admin_identity).to receive(:find_role_by_name).with('member').and_return(@member_role)
      allow(Admin::IdentityService).to receive(:admin_identity).and_return(admin_identity)
      expect(Admin::IdentityService.admin_identity).to receive(:grant_domain_user_role).with(@current_user.user_domain_id,@current_user.id,@member_role.id)
      
      Admin::IdentityService.create_user_domain_role(@current_user,'member')
    end
  end
  
end
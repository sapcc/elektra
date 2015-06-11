require 'spec_helper'

RSpec.describe Openstack::IdentityService do

  describe "required methods" do
    instance_methods = Openstack::IdentityService.instance_methods
    required_methods = [
      :forms_project, :find_project, :create_project, :grant_project_role, 
      :forms_credential, :find_credential, :create_credential  
    ]
    
    required_methods.each do |m|
      it { expect(instance_methods.include?(m)).to eq(true)}
    end
  end
end
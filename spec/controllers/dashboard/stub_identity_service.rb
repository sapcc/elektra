require 'spec_helper'

module StubIdentityService
  def self.included(klass)
    klass.before :each do
      allow_any_instance_of(Openstack::IdentityService).to receive(:projects).and_return(double("projects",auth_projects: []))
    end
  end
end
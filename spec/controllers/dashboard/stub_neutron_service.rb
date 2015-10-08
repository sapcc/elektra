require 'spec_helper'

module StubVolumeService
  def self.included(klass)
    klass.before :each do
      allow_any_instance_of(Openstack::NeutronService).to receive(:networks).and_return(double("networks"))
    end
  end
end
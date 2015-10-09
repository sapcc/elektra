require 'spec_helper'

module StubNetworkService
  def self.included(klass)
    klass.before :each do
      allow_any_instance_of(Openstack::NetworkService).to receive(:networks).and_return(double("networks"))
      allow_any_instance_of(Openstack::NetworkService).to receive(:driver).and_return(double("driver"))
    end
  end
end
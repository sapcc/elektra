require 'spec_helper'

module StubAdminIdentityService
  def self.included(klass)
    klass.before :each do
      # stub here methods of admin_identity
    end
  end
end
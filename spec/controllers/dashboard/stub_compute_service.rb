require 'spec_helper'

module StubComputeService
  def self.included(klass)
    klass.before :each do
      # stub here methods of compute
    end
  end
end
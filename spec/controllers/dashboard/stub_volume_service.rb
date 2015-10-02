require 'spec_helper'

module StubVolumeService
  def self.included(klass)
    klass.before :each do
      # stub here methods of volume
    end
  end
end
require 'spec_helper'

describe KeyManager::Container do

  it "should trim the attributes" do
    container = KeyManager::Container.new({'name' => ' test a'})
    container.valid?
    expect(container.name).to eq('test a')
  end

end

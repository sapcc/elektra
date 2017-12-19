require 'spec_helper'

describe KeyManager::Secret do

  it 'should trim the attributes' do
    secret = KeyManager::Secret.new(nil, 'name' => ' test a')
    secret.valid?
    expect(secret.name).to eq('test a')
  end
end

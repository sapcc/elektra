require 'spec_helper'

describe Lbaas::Listener do
  describe 'loading nested hashes' do
    it 'should succeed validation wiht the minimum of attributes' do
      listener = ::Lbaas::Listener.new(nil, protocol_port: '1',
                                                    protocol: 'HTTP')

      expect(listener).to be_valid
    end

    it 'should validate presence of default_tls_container_ref when protocol is TERMINATED_HTTPS' do
      listener = ::Lbaas::Listener.new(nil, protocol_port: '1',
                                                    protocol: 'TERMINATED_HTTPS')
      expect(listener).to_not be_valid
      expect(listener.errors[:default_tls_container_ref]).to_not be_nil
    end

    it 'should validates successfully presence of default_tls_container_ref' do
      listener = ::Lbaas::Listener.new(nil, protocol_port: '1',
                                                    protocol: 'TERMINATED_HTTPS',
                                                    default_tls_container_ref: 'some_ref')
      expect(listener).to be_valid
    end
  end
end

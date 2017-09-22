# frozen_string_literal: true
require 'spec_helper'

describe Compute::Server do
  let(:server) {
    Compute::Server.new(nil, addresses:
      {
        'Network 1' => [
          {
            'OS-EXT-IPS-MAC:mac_addr' => 'fa:16:3e:c0:7a:2b',
            'version' => 4,
            'addr' => '10.180.0.33',
            'OS-EXT-IPS:type' => 'fixed'
          },
          {
            'OS-EXT-IPS-MAC:mac_addr' => 'fa:16:3e:a5:e4:b4',
            'version' => 4,
            'addr' => '10.180.0.60',
            'OS-EXT-IPS:type' => 'fixed'
          },
          {
            'OS-EXT-IPS-MAC:mac_addr' => 'fa:16:3e:c0:7a:2b',
            'version' => 4,
            'addr' => '10.44.32.21',
            'OS-EXT-IPS:type' => 'floating'
          }
        ],
        'Network 2' =>  [
          {
            'OS-EXT-IPS-MAC:mac_addr' => 'fa:16:3e:df:c0:83',
            'version' => 4,
            'addr' => '10.180.0.17',
            'OS-EXT-IPS:type' => 'fixed'
          }
        ]
      })
  }

  describe '#add_floating_ip_to_addresses' do
    it 'responds to add_floating_ip_to_addresses' do
      expect(server).to respond_to(:add_floating_ip_to_addresses)
    end

    it 'extends addresses with a floating ip' do
      server.add_floating_ip_to_addresses('fa:16:3e:df:c0:83', '156.23.45.67')
      expect(server.addresses['Network 2']).to eq([
        {
          'OS-EXT-IPS-MAC:mac_addr' => 'fa:16:3e:df:c0:83',
          'version' => 4,
          'addr' => '10.180.0.17',
          'OS-EXT-IPS:type' => 'fixed'
        },
        {
          'OS-EXT-IPS-MAC:mac_addr' => 'fa:16:3e:df:c0:83',
          'addr' => '156.23.45.67',
          'OS-EXT-IPS:type' => 'floating'
        }
      ])
    end

    it 'should not add floating ip address' do
      server.add_floating_ip_to_addresses('BAD_MAC_ADDRESS', '156.23.45.67')
      expect(server.addresses['Network 2'].length).to eq(1)
    end
  end

  describe '#remove_floating_ip_from_addresses' do
    it 'responds to remove_floating_ip_from_addresses' do
      expect(server).to respond_to(:remove_floating_ip_from_addresses)
    end

    it 'removes floating ip from addresses' do
      server.remove_floating_ip_from_addresses('fa:16:3e:c0:7a:2b', '10.44.32.21')
      expect(server.addresses['Network 1']).to eq([
        {
          'OS-EXT-IPS-MAC:mac_addr' => 'fa:16:3e:c0:7a:2b',
          'version' => 4,
          'addr' => '10.180.0.33',
          'OS-EXT-IPS:type' => 'fixed'
        },
        {
          'OS-EXT-IPS-MAC:mac_addr' => 'fa:16:3e:a5:e4:b4',
          'version' => 4,
          'addr' => '10.180.0.60',
          'OS-EXT-IPS:type' => 'fixed'
        }
      ])
    end

    it 'should not remove floating ip address' do
      server.remove_floating_ip_from_addresses('BAD_MAC_ADDRESS', '10.44.32.21')
      expect(server.addresses['Network 1'].length).to eq(3)
    end
  end

  describe '#find_ips_map_by_ip' do
    it 'returns a hash with fixed ip' do
      expect(server.find_ips_map_by_ip('10.180.0.60').keys).to eq(%w[fixed])
    end

    it 'returns a hash with fixed and floating ips' do
      expect(server.find_ips_map_by_ip('10.180.0.33').keys).to eq(%w[fixed floating])
    end

    it 'returns a hash with fixed and floating ips by floating ip' do
      expect(server.find_ips_map_by_ip('10.44.32.21').keys).to eq(%w[fixed floating])
    end
  end

  describe '#ips' do
    it 'responds to ips' do
      expect(server).to respond_to(:ips)
    end

    it 'returns a hash map' do
      expect(server.ips.is_a?(Hash)).to eq(true)
    end

    it 'returns a map with two keys' do
      expect(server.ips.keys.length).to eq(2)
    end

    it 'returns a map where keys are network names' do
      expect(server.ips.keys.sort).to eq(['Network 1', 'Network 2'])
    end

    it 'map of Network 1 contains two entries' do
      expect(server.ips['Network 1'].length).to eq(2)
    end

    it 'map of Network 2 contains one entry' do
      expect(server.ips['Network 2'].length).to eq(1)
    end

    context 'Floating IP is assigned' do
      let(:ips) do
        server.ips['Network 1'].find do |ip|
          ip['fixed']['addr'] == '10.180.0.33'
        end
      end

      it 'contains fixed and floating keys' do
        expect(ips.keys.sort).to eq(%w[fixed floating])
      end

      it 'contains fixed and floating ips with the same MAC address' do
        expect(ips['fixed']['OS-EXT-IPS-MAC:mac_addr']).to eq(ips['floating']['OS-EXT-IPS-MAC:mac_addr'])
      end
    end

    context 'Floating IP is not assigned' do
      let(:ips) do
        server.ips['Network 1'].find do |ip|
          ip['fixed']['addr'] == '10.180.0.60'
        end
      end

      it 'contains only fixed IP' do
        expect(ips.keys).to eq(%w[fixed])
      end
    end
  end
end

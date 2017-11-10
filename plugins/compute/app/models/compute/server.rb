# frozen_string_literal: true

require 'base64'

module Compute
  # Represents the Openstack Server
  class Server < Core::ServiceLayerNg::Model
    validates :name, presence: { message: 'Please provide a name' }
    validates :image_id, presence: { message: 'Please select an image' }
    validates :flavor_id, presence: { message: 'Please select a flavor' }
    validates :network_ids, presence: {
      message: 'Please select at least one network'
    }
    validates :keypair_id, presence: {
      message: "Please choose a keypair for us to provision to the server.
      Otherwise you will not be able to log in."
    }

    NO_STATE    = 0
    RUNNING     = 1
    BLOCKED     = 2
    PAUSED      = 3
    SHUT_DOWN   = 4
    SHUT_OFF    = 5
    CRASHED     = 6
    SUSPENDED   = 7
    FAILED      = 8
    BUILDING    = 9

    def power_state_string
      case power_state
      when RUNNING then 'Running'
      when BLOCKED then 'Blocked'
      when PAUSED then 'Paused'
      when SHUT_DOWN then 'Shut down'
      when SHUT_OFF then 'Shut off'
      when CRASHED then 'Crashed'
      when SUSPENDED then 'Suspended'
      when FAILED then 'Failed'
      when BUILDING then 'Building'
      else
        'No State'
      end
    end

    def attributes_for_create
      params = {
        'name'              => read('name'),
        'imageRef'          => read('image_id'),
        'flavorRef'         => read('flavor_id'),
        'max_count'         => read('max_count'),
        'min_count'         => read('min_count'),
        # Optional
        'availability_zone' => read('availability_zone_id'),
        'key_name'          => read('keypair_id'),
        'metadata'          => read('metadata'),
        'user_data'         => Base64.encode64(read('user_data'))
      }.delete_if { |_k, v| v.blank? }

      security_group_names = read('security_groups')
      if security_group_names && security_group_names.is_a?(Array)
        params['security_groups'] = security_group_names.collect do |sg|
          { 'name' => sg }
        end
      end

      networks = read('network_ids')
      if networks && networks.is_a?(Array)
        params['networks'] = {

        }
        params['networks'] = networks.collect do |n|
          network = { 'uuid' => n['id'] }
          network['fixed_ip'] = n['fixed_ip'] if n['fixed_ip']
          network['port'] = n['port'] if n['port']
          network['tag'] = n['tag'] if n['tag']
          network
        end
      end
      # byebug
      params
    end

    def security_groups
      read('security_groups') || []
    end

    def security_groups_details
      @service.security_groups_details(id)
    end

    def availability_zone
      read('OS-EXT-AZ:availability_zone')
    end

    def power_state
      read('OS-EXT-STS:power_state')
    end

    def vm_state
      read('OS-EXT-STS:vm_state')
    end

    def attr_host
      read('OS-EXT-SRV-ATTR:host')
    end

    def volumes_attached
      read('os-extended-volumes:volumes_attached')
    end

    def task_state
      task_state = read('OS-EXT-STS:task_state')
      return nil if task_state.blank? || task_state.casecmp('none').zero?
      task_state
    end

    # borrowed from fog
    def ip_addresses
      addresses ? addresses.values.flatten.map { |x| x['addr'] } : []
    end

    def floating_ips
      @floating_ips ||= addresses.values.flatten.select do |ip|
        ip['OS-EXT-IPS:type'] == 'floating'
      end
    end

    # This methods converts addresses to a map between fixed and floating ips.
    # return:
    # { NETWORK_NAME => [{ 'fixed' => IP_DATA, 'floating' => IP_DATA}, ...] }
    def ips
      # for each entry in addresses
      addresses.each_with_object({}) do |(network_name, ips), ips_hash|
        # network_name => [{'fixed' => ip_data, 'floating' => ip_data}, ..]
        ips_hash[network_name] = ips.each_with_object({}) do |ip_data, mac_address_ips|
          mac_addr = ip_data['OS-EXT-IPS-MAC:mac_addr']
          ip_type = ip_data['OS-EXT-IPS:type']
          mac_address_ips[mac_addr] ||= {}
          mac_address_ips[mac_addr][ip_type] = ip_data
        end.values
      end
    end

    def find_ips_map_by_ip(ip_addr)
      ips.each do |_n, ips|
        ips.each do |ip|
          if (ip['floating'] && ip['floating']['addr'] == ip_addr) ||
             (ip['fixed'] && ip['fixed']['addr'] == ip_addr)
            return ip
          end
        end
      end
      nil
    end

    def add_floating_ip_to_addresses(mac_address, floating_ip_address)
      addresses.each do |_n, ips|
        ips.each do |ip_data|
          if ip_data['OS-EXT-IPS-MAC:mac_addr'] == mac_address
            ips << {
              'OS-EXT-IPS-MAC:mac_addr' => mac_address,
              'addr' => floating_ip_address,
              'OS-EXT-IPS:type' => 'floating'
            }
            return addresses
          end
        end
      end
    end

    def remove_floating_ip_from_addresses(mac_address, floating_ip_address)
      addresses.each do |_n, ips|
        ips.delete_if do |ip_data|
          ip_data['OS-EXT-IPS-MAC:mac_addr'] == mac_address &&
            ip_data['addr'] == floating_ip_address &&
            ip_data['OS-EXT-IPS:type'] == 'floating'
        end
      end
    end
    #
    # def remove_floating_ip_from_addresses(floating_ip)
    #
    # end
    #
    # def add_fixed_ip_to_addresses(interface)
    # end
    #
    # def remove_fixed_ip_from_addresses(interface)
    # end

    def fixed_ips
      ip_addresses_by_type('fixed')
    end

    def floating_ip_addresses
      ip_addresses_by_type('floating')
    end

    # borrowed from fog
    def ip_addresses_by_type(type)
      ips = if addresses
                      addresses.values.flatten.select do |data|
                        data['OS-EXT-IPS:type'] == 'floating'
                      end.map { |addr| addr['addr'] }
                    else
                      []
                    end
      return [] if ips.empty?
      # Return them all, leading with manually assigned addresses
      manual = ips.map { |addr| addr['ip'] }

      ips.sort do |a, b|
        a_manual = manual.include? a
        b_manual = manual.include? b

        if a_manual && !b_manual
          -1
        elsif !a_manual && b_manual
          1
        else
          0
        end
      end
      ips.empty? ? manual : ips
    end

    def flavor_object
      return nil unless flavor['id']
      @flavor_object ||= @service.find_flavor(flavor['id'], true)
    end

    def image_object
      return nil unless image['id']
      @image_object ||= @service.find_image(image['id'], true)
    end

    def metadata
      attribute_to_object('metadata', Compute::Metadata)
    end

    def networks
      attribute_to_object('networks', Compute::Metadata)
    end

    def attached_volumes
      return [] if volumes_attached.empty?
      @service.volumes(id)
    end

    ####################### ACTIONS #####################
    def add_fixed_ip(network_id)
      requires :id
      @service.add_fixed_ip(id,network_id)
    end

    def remove_fixed_ip(ip_address)
      requires :id
      @service.remove_fixed_ip(id,ip_address)
    end

    def terminate
      requires :id
      @service.delete_server id
    end

    def rebuild(image_ref, name, admin_pass = nil, metadata = nil, personality = nil)
      requires :id
      @service.rebuild_server(id, image_ref, name, admin_pass, metadata, personality)
      true
    end

    def resize(flavor_ref)
      requires :id
      @service.resize_server(id, flavor_ref)
      true
    end

    def revert_resize
      requires :id
      @service.revert_resize_server(id)
      true
    end

    def confirm_resize
      requires :id
      @service.confirm_resize_server(id)
      true
    end

    def reboot(type = 'SOFT')
      requires :id
      @service.reboot_server(id, type)
      true
    end

    def stop
      requires :id
      @service.stop_server(id)
    end

    def pause
      requires :id
      @service.pause_server(id)
    end

    def suspend
      requires :id
      @service.suspend_server(id)
    end

    def start
      requires :id

      case status.downcase
      when 'paused'
        @service.unpause_server(id)
      when 'suspended'
        @service.resume_server(id)
      else
        @service.start_server(id)
      end
    end

    def lock
      requires :id
      @service.lock_server(id)
    end

    def unlock
      requires :id
      @service.unlock_server(id)
    end

    def create_image(name, metadata = {})
      requires :id
      @service.create_image(id, name, metadata)
      true
    end

    def reset_vm_state(vm_state)
      requires :id
      @service.reset_server_state id, vm_state
      true
    end

    def attach_volume(volume_id, device_name)
      requires :id
      @service.attach_volume(volume_id, id, device_name)
      true
    end

    def detach_volume(volume_id)
      requires :id
      @service.detach_volume(id, volume_id)
      true
    end

    def assign_security_group(sg_id)
      requires :id
      @service.add_security_group(id, sg_id)
      true
    end

    def unassign_security_group(sg_id)
      requires :id
      @service.remove_security_group(id, sg_id)
      true
    end
  end
end

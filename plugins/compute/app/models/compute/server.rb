# frozen_string_literal: true

require 'base64'

module Compute
  # Represents the Openstack Server
  class Server < Core::ServiceLayer::Model
    validates :name, presence: { message: 'Please provide a name' }
    validates :image_id, presence: { message: 'Please select an image' }, if: :new?
    validates :flavor_id, presence: { message: 'Please select a flavor' }, if: :new?
    validate :validate_network, if: :new?
    validates :keypair_id, presence: {
      message: "Please choose a keypair for us to provision to the server.
      Otherwise you will not be able to log in."
    }, if: :new?

    validates_format_of :name, without: /\A.*\.\d+\Z/

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
          network = {}
          network['uuid'] = n['id'] if n['port'].blank?
          network['fixed_ip'] = n['fixed_ip'] if n['port'].blank?
          network['port'] = n['port']
          network['tag'] = n['tag']
          network.delete_if { |_k, v| v.blank? }
          network
        end
      end
      # byebug
      params
    end

    def attributes_for_update
      {
        'name'              => read('name')
      }.delete_if { |_k, v| v.blank? }
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
    # [
    #   {
    #     'fixed' => { 'addr' => ADDRESS, 'network_name' => NETWORK_NAME},
    #     'floating' => { 'addr' => ADDRESS, 'network_name' => NETWORK_NAME}
    #   },
    #   ...
    # ]
    def ip_maps(project_floating_ips)
      return @ip_maps if @ip_maps
      return {} unless addresses

      ip_network_names = {}
      server_floating_ips = []

      addresses.each do |network_name, ips|
        ips.each do |ip|
          ip_network_names[ip['addr']] = network_name
          if ip['OS-EXT-IPS:type'] == 'floating'
            server_floating_ips << ip['addr']
          end
        end
      end

      fixed_floating_map = project_floating_ips.each_with_object({}) do |fip, map|
        next unless server_floating_ips.include?(fip.floating_ip_address)
        map[fip.fixed_ip_address] = fip
      end

      @ip_maps = addresses.values.flatten.each_with_object([]) do |ip, array|
        next if ip['OS-EXT-IPS:type'] == 'floating'

        fixed_address = ip['addr']
        floating_ip = fixed_floating_map[fixed_address]
        data = {
          'fixed' => {
            'addr' => fixed_address,
            'network_name' => ip_network_names[fixed_address]
          }
        }
        if floating_ip
          data['floating'] = {
            'addr' => floating_ip.floating_ip_address,
            'id' => floating_ip.id,
            'network_name' => ip_network_names[floating_ip.floating_ip_address]
          }
        end
        array << data
      end
    end

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

    def locked?
      metadata.locked == true || metadata.locked == 'true'
    end

    def lock
      # Since the locked attribute is available in version 2.9 and we use 2.1
      # we need to simulate this attribute. For that we use the server
      # metadata
      requires :id
      tries = 1
      begin
        # try to update locked attribute in server metadata.
        # It can fail with 409 if server already locked.
        @service.update_metadata_key(id, 'locked', 'true')
        @service.lock_server(id)
      rescue Elektron::Errors::ApiResponse => e
        if e.code == 409 && !locked? && tries > 0
          tries -= 1
          # unlock server and try again to lock
          @service.unlock_server(id) && retry
        end
      ensure
        self.attributes = @service.find_server(id).attributes
        true
      end
    end

    def unlock
      requires :id
      begin
        @service.unlock_server(id)
        @service.update_metadata_key(id, 'locked', 'false')
      ensure
        self.attributes = @service.find_server(id).attributes
        true
      end
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

    protected

    def new?
      id.nil?
    end

    def validate_network
      ids = network_ids.each_with_object([]) do |n, a|
        a << n['id'] unless n['id'].blank?
      end

      return if network_ids && network_ids.length.positive? && ids.length.positive?
      errors.add(:network_ids, 'Please select a network')
    end
  end
end

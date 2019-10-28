# frozen_string_literal: true

module Lbaas
  # represents openstack lb
  class Loadbalancer < Core::ServiceLayer::Model
    validates :vip_subnet_id, presence: true, if: -> { id.nil? }

    def in_transition?
      return false
      # if self.provisioning_status.start_with?('PENDING')
      #   return true
      # else
      #   return false
      # end
    end

    def active?
      return true
      # if self.provisioning_status == 'ACTIVE'
      #   return true
      # else
      #   return false
      # end
    end

    def delete?
      listeners.blank? && pools.blank?
    end

    def attributes_for_create
      {
        'vip_subnet_id'   => read('vip_subnet_id'),
        'name'            => read('name'),
        'description'     => read('description'),
        'vip_address'     => read('vip_address'),
        'provider'        => read('provider'),
        'flavor'          => read('flavor'),
        'admin_state_up'  => read('admin_state_up'),
        'project_id'       => read('project_id'),
        'project_id'      => read('project_id')
      }.delete_if { |_k, v| v.blank? }
    end

    def attributes_for_update
      {
        'name'            => read('name'),
        'description'     => read('description'),
        'admin_state_up'  => read('admin_state_up')
      }.delete_if { |k, v| v.blank? and !%w[name description].include?(k) }
    end
  end
end

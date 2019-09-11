# frozen_string_literal: true

module Loadbalancing
  # represents lbaas pool member
  class PoolMember < Core::ServiceLayer::Model
    attr_accessor :id
    validates :address, presence: true
    validates :weight, presence: true, inclusion: {
      in: '1'..'256',
      message: 'Choose a weight between 1 and 256'
    }
    validates :protocol_port, presence: true, inclusion: {
      in: '1'..'65535',
      message: 'Choose a port between 1 and 65535'
    }

    attr_accessor :in_transition

    def in_transition?
      false
    end

    def attributes_for_create
      {
        'address'       => read('address'),
        'project_id'    => read('project_id'),
        'protocol_port' => read('protocol_port'),
        'weight'         => read('weight'),
        'subnet_id'     => read('subnet_id'),
        'tenant_id'     => read('tenant_id')
      }.delete_if { |_k, v| v.blank? }
    end

    def attributes_for_update
      {
        'admin_state_up' => read('admin_state_up'),
        'weight'         => read('weight')
      }.delete_if { |_k, v| v.blank? }
    end

    def perform_service_create(create_attributes)
      service.create_pool_member(pool_id, create_attributes)
    end

    def perform_service_update(member_id, update_attributes)
      service.update_pool_member(pool_id, member_id, update_attributes)
    end

    def perform_service_delete(member_id)
      service.delete_pool_member(pool_id, member_id)
    end
  end
end

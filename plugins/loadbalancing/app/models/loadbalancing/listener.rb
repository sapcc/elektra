# frozen_string_literal: true

module Loadbalancing
  # represents openstack lb listener
  class Listener < Core::ServiceLayer::Model
    PROTOCOLS = %w[HTTP TCP TERMINATED_HTTPS].freeze

    validates :name, presence: false
    validates :protocol, presence: true
    validates :protocol_port, presence: true, inclusion: {
      in: '1'..'65535',
      message: 'Choose a port between 1 and 65535'
    }
    validates_presence_of :default_tls_container_ref, message: 'A certificate container is needed for TERMINATED_HTTPS Listeners',
                                                      if: -> { protocol == 'TERMINATED_HTTPS' }

    attr_accessor :in_transition

    def in_transition?
      false
    end

    def attributes_for_create
      {
        'loadbalancer_id' => read('loadbalancer_id'),
        'name' => read('name'),
        'description' => read('description'),
        'admin_state_up' => read('admin_state_up'),
        'connection_limit' => read('connection_limit'),
        'default_pool_id' => read('default_pool_id'),
        'default_tls_container_ref' => read('default_tls_container_ref'),
        'protocol' => read('protocol'),
        'protocol_port' => read('protocol_port'),
        'sni_container_refs' => read('sni_container_refs'),
        'project_id' => read('project_id'),
        'tenant_id' => read('tenant_id')
      }.delete_if { |_k, v| v.blank? }
    end

    def attributes_for_update
      {
        'name' => read('name'),
        'description' => read('description'),
        'admin_state_up' => read('admin_state_up'),
        'connection_limit' => read('connection_limit'),
        'default_pool_id' => read('default_pool_id'),
        'default_tls_container_ref' => read('default_tls_container_ref'),
        'sni_container_refs' => read('sni_container_refs')
      }.delete_if { |k, v| v.blank? && !%w[name description default_pool_id sni_container_refs connection_limit].include?(k) }
    end
  end
end

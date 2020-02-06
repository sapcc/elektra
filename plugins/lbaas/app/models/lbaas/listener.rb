# frozen_string_literal: true

module Lbaas
  # represents openstack lb listener
  class Listener < Core::ServiceLayer::Model

    PROTOCOLS = %w[HTTP HTTPS TERMINATED_HTTPS TCP UDP].freeze

    INSERT_HEADERS = {}
    INSERT_HEADERS['HTTP'] = %w[X-Forwarded-For X-Forwarded-Port X-Forwarded-Proto].freeze
    INSERT_HEADERS['HTTPS'] = INSERT_HEADERS['HTTP']
    INSERT_HEADERS['TERMINATED_HTTPS'] = INSERT_HEADERS['HTTP'] + %w[X-SSL-Client-Verify X-SSL-Client-Has-Cert X-SSL-Client-DN X-SSL-Client-CN X-SSL-Issuer X-SSL-Client-SHA1 X-SSL-Client-Not-Before X-SSL-Client-Not-After].freeze
    INSERT_HEADERS['TCP'] = %w[].freeze
    INSERT_HEADERS['UDP'] = %w[].freeze

    CLIENT_AUTHENTICATION = %w[NONE OPTIONAL MANDATORY]

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
        'project_id' => read('project_id'),
        'insert_headers' => read('insert_headers'),
        'client_authentication' => read('client_authentication'),
        'client_ca_tls_container_ref' => read('client_ca_tls_container_ref'),
        'tags'                      => read('tags')
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
        'sni_container_refs' => read('sni_container_refs'),
        'insert_headers' => read('insert_headers'),
        'client_authentication' => read('client_authentication'),
        'client_ca_tls_container_ref' => read('client_ca_tls_container_ref'),
        'tags'                      => read('tags')
      }.delete_if { |k, v| v.blank? && !%w[name description default_pool_id sni_container_refs connection_limit insert_headers].include?(k) }
    end
  end
end

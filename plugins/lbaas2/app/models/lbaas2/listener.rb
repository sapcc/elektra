# frozen_string_literal: true

module Lbaas2
  class Listener < Core::ServiceLayer::Model

    validates :name, presence: true
    validates :protocol, presence: true
    validates :protocol_port, presence: true, inclusion: {
      in: 1..65535,
      message: 'Choose a port between 1 and 65535'
    }
    validates_presence_of :default_tls_container_ref, message: 'A certificate container is needed for TERMINATED_HTTPS Listeners',
                                                      if: -> { protocol == 'TERMINATED_HTTPS' }

    def attributes_for_create
      {
        'loadbalancer_id' => read('loadbalancer_id'),
        'name' => read('name'),
        'description' => read('description'),
        'connection_limit' => read('connection_limit'),
        'default_pool_id' => read('default_pool_id'),
        'default_tls_container_ref' => read('default_tls_container_ref'),
        'protocol' => read('protocol'),
        'protocol_port' => read('protocol_port'),
        'sni_container_refs' => read('sni_container_refs'),
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
      }
    end

  end
end
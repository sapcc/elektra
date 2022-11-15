# frozen_string_literal: true

module Lbaas2
  class Pool < Core::ServiceLayer::Model

    validates :lb_algorithm, presence: true
    validates :protocol, presence: true
    validates_presence_of :session_persistence_cookie_name,
    if: :app_cookie?,
    message: 'Please enter a Cookie Name in case of ' \
             'Application Cookie persistence'

    def app_cookie?
      session_persistence_type == 'APP_COOKIE'
    end

    def attributes_for_create
      {
        'listener_id'               => read('listener_id'),
        'loadbalancer_id'           => read('loadbalancer_id'),
        'project_id'                => read('project_id'),
        'name'                      => read('name'),
        'description'               => read('description'),
        'admin_state_up'            => read('admin_state_up'),
        'lb_algorithm'              => read('lb_algorithm'),        
        'protocol'                  => read('protocol'),
        'session_persistence'       => read('session_persistence'),
        'tls_enabled'               => read('tls_enabled'),
        'tls_container_ref'         => read('tls_container_ref'),
        'ca_tls_container_ref'      => read('ca_tls_container_ref'),
        'tags'                      => read('tags'),
        'tls_ciphers'               => read('tls_ciphers')
      }.delete_if { |_k, v| v.blank? }
    end

    def attributes_for_update
      {
        'name'                      => read('name'),
        'description'               => read('description'),
        'lb_algorithm'              => read('lb_algorithm'),
        'session_persistence'       => read('session_persistence'),        
        'tls_enabled'               => read('tls_enabled'),
        'tls_container_ref'         => read('tls_container_ref'),
        'ca_tls_container_ref'      => read('ca_tls_container_ref'),
        'tags'                      => read('tags'),
        'tls_ciphers'               => read('tls_ciphers')
      }
    end

  end
end
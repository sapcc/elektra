# frozen_string_literal: true

module Lbaas
  # represents openstack lbaas pool
  class Pool < Core::ServiceLayer::Model
    ALGORITHMS = %w[ROUND_ROBIN LEAST_CONNECTIONS SOURCE_IP].freeze
    SESSION_PERSISTENCE_TYPES = %w[SOURCE_IP HTTP_COOKIE APP_COOKIE].freeze
    PROTOCOLS = %w[TCP HTTP HTTPS].freeze

    # validates :name, presence: true
    validates :lb_algorithm, presence: true
    validates :protocol, presence: true
    # validates :listener_id, presence: true
    validates_presence_of :session_persistence_cookie_name,
                          if: :app_cookie?,
                          message: 'Please enter a Cookie Name in case of ' \
                                   'Application Cookie persistence'

    # validate :listener_or_loadbalancer

    def app_cookie?
      session_persistence_type == 'APP_COOKIE'
    end

    def session_persistence_type
      return session_persistence['type'] if session_persistence
      ''
    end

    def session_persistence_cookie_name
      return session_persistence['cookie_name'] if session_persistence
      ''
    end

    def listener_or_loadbalancer
      return unless listener_id.blank? && loadbalancer_id.blank?
      errors.add(:loadbalancer_id, 'Please choose a listener or a ' \
                                   'loadbalancer where the pool should ' \
                                   'belong to')
      errors.add(:listener_id, 'Please choose a listener or a loadbalancer ' \
                               'where the pool should belong to')
    end

    def attributes_for_create
      {
        'listener_id'               => read('listener_id'),
        'loadbalancer_id'           => read('loadbalancer_id'),
        'name'                      => read('name'),
        'description'               => read('description'),
        'admin_state_up'            => read('admin_state_up'),
        'lb_algorithm'              => read('lb_algorithm'),
        'session_persistence'       => read('session_persistence'),
        'protocol'                  => read('protocol'),
        'subnet_id'                 => read('subnet_id'),
        'project_id'                => read('project_id'),
        'project_id'                 => read('project_id')
      }.delete_if { |_k, v| v.blank? }
    end

    def attributes_for_update
      {
        'name'                      => read('name'),
        'description'               => read('description'),
        'admin_state_up'            => read('admin_state_up'),
        'session_persistence'       => read('session_persistence'),
        'lb_algorithm'              => read('lb_algorithm')
      }.delete_if { |k, v| v.blank? and !%w[name description session_persistence].include?(k) }
    end
  end
end

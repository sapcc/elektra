# frozen_string_literal: true

module Loadbalancing
  # represents openstack lbaas l7 policy
  class L7policy < Core::ServiceLayer::Model
    include ActiveModel::Conversion

    PREDEFINED_POLICIES = [
      {
        protocols: %w[TCP],
        ids: %w[proxy_protocol_2edF_v1_0 proxy_protocol_V2_e8f6_v1_0 standard_tcp_a3de_v1_0]
      },
      {
        protocols: %w[HTTP HTTPS TERMINATED_HTTPS],
        ids: %w[x_forward_5b6e_v1_0 no_one_connect_3caB_v1_0
                http_compression_e4a2_v1_0 cookie_encryption_b82a_v1_0]
      },
      { protocols: ['TERMINATED_HTTPS'], ids: ['sso_22b0_v1_0'] },
      { protocols: ['HTTP'], ids: ['http_redirect_a26c_v1_0'] }
    ].freeze

    ACTIONS = %w[REDIRECT_TO_URL REDIRECT_TO_POOL REJECT].freeze

    validates :action, presence: true
    validates :name, presence: false
    # validates :redirect_pool_id, presence: {
    #   message: 'Please choose a Pool for redirection'
    # }, if: :action == 'REDIRECT_TO_POOL'
    # validates :redirect_url, presence: {
    #   message: 'Please choose a Url for redirection'
    # }, if: :action == 'REDIRECT_TO_URL'

    attr_accessor :in_transition

    def in_transition?
      false
    end

    def predefined?
      PREDEFINED_POLICIES.each do |p|
        return true if p[:ids].include? name
      end
      false
    end

    def self.predefined(protocol)
      PREDEFINED_POLICIES.each_with_object([]) do |p, policies|
        policies << p if p[:protocols].include? protocol
      end
    end

    def attributes_for_create
      {
        'listener_id' => read('listener_id'),
        'action' => read('action'),
        'tenant_id' => read('tenant_id'),
        'name' => read('name'),
        'description' => read('description'),
        'redirect_pool_id' => read('redirect_pool_id'),
        'redirect_url' => read('redirect_url'),
        'position' => read('position')
      }.delete_if { |_k, v| v.blank? }
    end

    def attributes_for_update
      {
        'action' => read('action'),
        'name' => read('name'),
        'description' => read('description'),
        'redirect_pool_id' => read('redirect_pool_id'),
        'redirect_url' => read('redirect_url'),
        'position' => read('position')
      }.delete_if { |k, v| v.blank? && !%w[name description redirect_pool_id redirect_url position].include?(k) }
    end
  end
end

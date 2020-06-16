# frozen_string_literal: true

module Lbaas2
  # represents openstack lb status
  class Statuses < Core::ServiceLayer::Model
    def state
      @state ||= (Hashie::Mash.new loadbalancer).extend Hashie::Extensions::DeepLocate
      @state.extend Hashie::Extensions::DeepFind
    end

    def find_state(id)
      state
      s = @state.deep_locate ->(key, value, _o) { key == 'id' && value == id }
      s.first
    end
  end
end

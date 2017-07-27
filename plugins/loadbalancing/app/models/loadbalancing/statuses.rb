module Loadbalancing
  class Statuses < Core::ServiceLayer::Model

    def state
      @state ||= (Hashie::Mash.new self.loadbalancer).extend Hashie::Extensions::DeepLocate
      @state.extend Hashie::Extensions::DeepFind
    end

    def find_state id
      state()
      s = @state.deep_locate -> (key, value, object) { key == 'id' && value == id }
      return s.first
    end

  end
end

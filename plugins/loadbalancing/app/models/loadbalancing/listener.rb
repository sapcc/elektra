module Loadbalancing
  class Listener < Core::ServiceLayer::Model
    PROTOCOLS= ['HTTP','TCP', 'HTTPS', 'TERMINATED_HTTPS']
    validates :name, presence: true
    validates :protocol, presence: true
    validates :protocol_port, presence: true, inclusion: { in: '1'..'65535',  message: "Choose a port between 1 and 65535" }
  end
end

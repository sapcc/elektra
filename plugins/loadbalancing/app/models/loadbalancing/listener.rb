module Loadbalancing
  class Listener < Core::ServiceLayer::Model
    PROTOCOLS= ['TCP', 'HTTP', 'HTTPS', 'TERMINATED_HTTPS']
    validates :name, presence: true
    validates :protocol, presence: true
    validates :protocol_port, presence: true, inclusion: { in: '1'..'65535',  message: "Choose a port between 1 and 65535" }
    validates :default_tls_container_ref, presence: { message: "A certificate container is needed for TERMINATED_HTTPS Listeners" }, if: "protocol == 'TERMINATED_HTTPS'"
  end
end

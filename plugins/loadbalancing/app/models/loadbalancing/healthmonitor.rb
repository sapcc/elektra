module Loadbalancing
  class Healthmonitor < Core::ServiceLayer::Model

    TYPES=['HTTP', 'PING', 'TCP']
    METHODS= ['GET', 'HEAD']

    validates :type, presence: true
    validates :delay, presence: true
    validates :max_retries, presence: true
  end
end

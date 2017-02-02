module Loadbalancing
  class Pool < Core::ServiceLayer::Model

    ALGORITHMS=['ROUND_ROBIN', 'LEAST_CONNECTIONS', 'SOURCE_IP']
    SESSION_PERSISTENCE_TYPES=['SOURCE_IP', 'HTTP_COOKIE', 'APP_COOKIE']
    PROTOCOLS=['TCP', 'HTTP', 'HTTPS']

    validates :name, presence: true
    validates :lb_algorithm, presence: true
    validates :protocol, presence: true
    #validates :listener_id, presence: true
    validates_presence_of :session_persistence_cookie_name, :if => :app_cookie?, message: "Please enter a Cookie Name in case of Application Cookie persistence"

    #validate :listener_or_loadbalancer

    def app_cookie?
      session_persistence_type == 'APP_COOKIE' ? true : false
    end

    def session_persistence_type
      return self.session_persistence['type'] if self.session_persistence
      return ''
    end

    def session_persistence_cookie_name
      return self.session_persistence['cookie_name'] if self.session_persistence
      return ''
    end

    def listener_or_loadbalancer
      if self.listener_id.blank? and self.loadbalancer_id.blank?
        errors.add(:loadbalancer_id, "Please choose a listener or a loadbalancer where the pool should belong to")
        errors.add(:listener_id, "Please choose a listener or a loadbalancer where the pool should belong to")
      end

    end
  end
end

module Loadbalancing
  class Healthmonitor < Core::ServiceLayer::Model

    TYPES=['TCP','PING','HTTP','HTTPS']
    METHODS= ['GET', 'HEAD', 'POST']

    validates :type, presence: true
    validates :delay, presence: true, numericality: { greater_than: 0}
    validates :max_retries, presence: true, inclusion: { in: '1'..'10', message: 'You can have between 1 and 10 retries'  }
    validate  :timeoutvalue

    def timeoutvalue
      if self.timeout.to_i <= 0
        errors.add(:timeout, 'Please enter a timeout greater 0')
      elsif self.timeout.to_i >= delay.to_i
        errors.add(:timeout, 'Please enter a timeout less than the "Delays" value')
      end
    end

    def http_type?
      return true if self.type && self.type.start_with?('HTTP')
      return false
    end

  end
end
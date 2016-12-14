module Loadbalancing
  class Loadbalancer < Core::ServiceLayer::Model
    validates :name, :vip_subnet_id, presence: true

    def in_transition?
      if self.provisioning_status.start_with?('PENDING')
        return true
      else
        return false
      end
    end

    def active?
      if self.provisioning_status == 'ACTIVE'
        return true
      else
        return false
      end
    end

    def delete?
      return (self.listeners.blank?  && self.pools.blank?)
    end

  end
end

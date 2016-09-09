module Loadbalancing
  class Loadbalancer < Core::ServiceLayer::Model
    validates :name, :vip_subnet_id, presence: true
  end
end

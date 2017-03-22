module Networking
  class Router < Core::ServiceLayer::Model
    validates :name, presence: { message: 'Please provide a name' }

    attr_accessor :internal_subnets
    validates :internal_subnets, presence: { message: 'Please select at least one subnet from the private networks' }

    def external_ip
      begin
        self.external_gateway_info["external_fixed_ips"].collect{|ips| ips["ip_address"]}.join(', ')
      rescue
        nil
      end
    end
    
    def external_gateway_info
      read("external_gateway_info") || {}
    end
  end
end

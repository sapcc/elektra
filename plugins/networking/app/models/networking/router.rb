module Networking
  class Router < Core::ServiceLayer::Model
    validates :name, presence: { message: 'Please provide a name' }

    def external_ip
      begin
        self.external_gateway_info["external_fixed_ips"].collect{|ips| ips["ip_address"]}.join(', ')
      rescue
        nil
      end
    end
  end
end

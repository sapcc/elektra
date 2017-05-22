module Networking
  class Router < Core::ServiceLayer::Model
    validates :name, presence: { message: 'Please provide a name' }

    attr_accessor :internal_subnets
    validates :internal_subnets, presence: { message: 'Please select at least one subnet from the private network subnets' }

    def ip_subnet_objects
      unless @ip_subnet_objects
        if external_gateway_info
          if external_gateway_info["external_fixed_ips"]
            ip_infos = external_gateway_info["external_fixed_ips"]
            ip_infos = [ip_infos] unless ip_infos.is_a?(Array)

            @ip_subnet_objects = ip_infos.inject({}) do |hash,ip_info|
              subnet = Rails.cache.fetch("subnet_#{id}", expires_in: 2.hours) do
                @driver.get_subnet(ip_info["subnet_id"])
              end
              hash[ip_info["ip_address"]] = Networking::Subnet.new(@driver,subnet)
              hash
            end
          end
        end
      end
      return @ip_subnet_objects
    end

    def network_object
      if external_gateway_info
        if external_gateway_info["network_id"]
          id = external_gateway_info["network_id"]
          network = Rails.cache.fetch("network_#{id}", expires_in: 2.hours) do
            @driver.get_network(id)
          end
          Networking::Network.new(@driver,network)
        end
      end
    end

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

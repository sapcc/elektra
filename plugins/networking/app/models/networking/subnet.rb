module Networking
  class Subnet < Core::ServiceLayer::Model
    validates :name, presence: true
    validates :cidr, presence: true

    def ip_version
      4
    end

    def attributes_for_create
      {
        "name" => name,
        "ip_version" => ip_version,
        "cidr" => cidr,
        "network_id" => network_id,
        "enable_dhcp" => ["1","true",1,true].include?(enable_dhcp)
      }.delete_if { |k, v| v.nil? }
    end
  end
end

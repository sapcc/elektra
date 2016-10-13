module Networking
  class Subnet < Core::ServiceLayer::Model
    validates :name, presence: true
    validates :cidr, presence: true
    validate :cidr_must_be_in_reserved_range

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

    def cidr_must_be_in_reserved_range
      unless cidr[/^(10\.180\.([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5]))\.([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])(\/([0-9]|[1-2][0-9]|3[0-2]))$/]
        errors.add(:cidr, "must be within the 10.180.0.0/16 range.")
      end
    end

  end
end

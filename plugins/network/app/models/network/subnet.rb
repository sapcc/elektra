module Network
  class Subnet < DomainModelServiceLayer::Model
    validates :name, presence: {message: 'Please provide a name'}
    
    def ip_version
      4
    end
    
    def create_attributes
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
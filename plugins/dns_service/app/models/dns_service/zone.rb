module DnsService
  class Zone < Core::ServiceLayer::Model
    validates :name, presence: {message: 'Please provide the domain name'}
    validates :email, presence: {message: 'Please provide an email'}

    def attributes_for_create
      zone_attributes = attributes
      zone_attributes[:ttl] = zone_attributes[:ttl].to_i if zone_attributes[:ttl]
      zone_attributes[:name] = zone_attributes[:name].strip if zone_attributes[:name]
      zone_attributes[:email] = zone_attributes[:email].strip if zone_attributes[:email]
      zone_attributes[:attributes] = zone_attributes[:attributes] if zone_attributes[:attributes]

      zone_attributes.delete(:id)
      zone_attributes.delete_if { |k, v| v.blank? }
    end

    def attributes_for_update
      zone_attributes = attributes
      zone_attributes[:ttl] = zone_attributes[:ttl].to_i if zone_attributes[:ttl]
      zone_attributes[:email] = zone_attributes[:email].strip if zone_attributes[:email]
      zone_attributes[:project_id] = zone_attributes[:project_id].strip if zone_attributes[:project_id]
      zone_attributes.delete(:name)
      zone_attributes.delete_if { |k, v| v.blank? }
    end

    # msp to driver create method
    def perform_driver_create(create_attributes)
      name  = create_attributes.delete("name")
      email = create_attributes.delete("email")
      @driver.create_zone(name, email, create_attributes)
    end
  end
end

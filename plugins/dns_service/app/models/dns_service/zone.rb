# frozen_string_literal: true

module DnsService
  # Presents the zone model
  class Zone < Core::ServiceLayer::Model
    validates :name,
          presence: {
            message: "Top-Level Domain (TLD) is required. Please provide a domain name.",
          }
    validates :email, presence: {
            message: "Email address is required. Please provide an email address."
          }

    validates :ttl, presence: {
            message: "Time-to-Live (TTL) value is required. Please provide a TTL value."
          }


    def attributes_for_create
      zone_attributes = {}
      zone_attributes[:ttl] = read("ttl").to_i if read("ttl")
      zone_attributes[:name] = read("name").strip if read("name")
      zone_attributes[:email] = read("email").strip if read("email")
      zone_attributes[:description] = read("description")
      zone_attributes[:attributes] = (
        read("attributes") || {}
      ).keep_if { |k, _v| %w[external label].include?(k) }
      # choose the pool where the zone should be created
      zone_attributes[:attributes][:pool_id] = read("pool_id").strip if read(
        "pool_id",
      ) && !read("pool_id").empty?
      # this is needed if a domain needs to be created directly in the given project
      zone_attributes[:project_id] = read("project_id").strip if read(
        "project_id",
      ) && !read("project_id").empty?

      zone_attributes.delete_if { |_k, v| v.blank? }
    end

    def attributes_for_update
      zone_attributes = attributes_for_create
      if read("project_id")
        zone_attributes[:project_id] = read("project_id").strip
      end
      zone_attributes.delete(:name)
      zone_attributes.delete_if { |_k, v| v.blank? }
    end
  end
end

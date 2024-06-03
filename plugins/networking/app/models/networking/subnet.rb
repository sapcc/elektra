# frozen_string_literal: true

module Networking
  # Implements Openstack Subnet
  class Subnet < Core::ServiceLayer::Model
    validates :name, presence: true
    validates :cidr, presence: true
    validate :cidr_must_be_in_reserved_range
    attr_accessor :check_cidr_range
    

    @@allowed_ranges_last_updated = Time.now
    @@allowed_ranges = nil
    @@allowed_ranges_raw = nil
    @@semaphore = Mutex.new

    def ip_version
      4
    end

    def attributes_for_create
      {
        "name" => name,
        "ip_version" => ip_version,
        "cidr" => cidr,
        "network_id" => network_id,
      }.delete_if { |_k, v| v.nil? }
    end

    def allowed_ranges
      return if cidr.nil?
      if !@@allowed_ranges.nil? &&
           @@allowed_ranges_last_updated > Time.now - 1.day
        return @@allowed_ranges
      end

      if ENV.key?("RAILS_ENV") && (ENV["RAILS_ENV"] == "test")
        return ["10.180.0.0/16"]
      end
      # prevent double loading if two user are creating a subnet at the same time
      @@semaphore.synchronize do
        @@allowed_ranges_last_updated = Time.now

        @@allowed_ranges = []
        begin
          uri =
            URI.parse(
              "https://netbox.global.cloud.sap/api/ipam/prefixes/?mask_length__lte=&q=&within_include=&fami[%E2%80%A6]ngth=&present_in_vrf_id=&is_pool=&tag=cc-net-tenant-range",
            )
          http = Net::HTTP.new(uri.host, uri.port)
          http.use_ssl = true
          if ENV.key?("ELEKTRA_SSL_VERIFY_PEER") &&
               (ENV["ELEKTRA_SSL_VERIFY_PEER"] == "false")
            http.verify_mode = OpenSSL::SSL::VERIFY_NONE
          end
          request = Net::HTTP::Get.new(uri.request_uri)
          response = http.request(request)
          json_data = JSON.parse(response.read_body)
          results = json_data["results"]
          results.each do |ip_data|
            prefix = ip_data["prefix"]
            @@allowed_ranges.push(prefix)
          end
        rescue e
          errors.add(
            :cidr,
            "Could not load the list of allowed cidr ranges: #{e.message}",
          )
          @@allowed_ranges = ["10.180.0.0/16"]
        end
      end

      return @@allowed_ranges
    end

    def cidr_must_be_in_reserved_range
      return if cidr.nil?
      unless cidr.match(
        /^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])(\/(3[0-2]|[1-2][0-9]|[0-9]))$/,
        )
        errors.add(:cidr, "must be a valid cidr adress like 10.180.1.0/16")
        return
      end
      
      return if self.check_cidr_range == false

      allowed_ranges.each do |allowed_range|
        allowed_network = IPAddr.new(allowed_range)
        given_cidr_range = IPAddr.new(cidr)
        return if allowed_network === given_cidr_range
      end

      errors.add(:cidr, "The given cidr #{cidr} is not a valid cidr or range")
      errors.add(:cidr, "Allowed ranges are #{allowed_ranges.join(", ")}")
    end
  end
end

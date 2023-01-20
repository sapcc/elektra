# frozen_string_literal: true

module Networking
  # Implements Openstack Subnet
  class Subnet < Core::ServiceLayer::Model
    validates :name, presence: true
    validates :cidr, presence: true
    validate :cidr_must_be_in_reserved_range

    @@allowed_ranges_last_updated = Time.now
    @@allowed_ranges = nil
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
      if !@@allowed_ranges.nil? &&
           @@allowed_ranges_last_updated > Time.now - 1.day
        return @@allowed_ranges
      end

      # prevent double loading if two user are creating a subnet at the same time
      @@semaphore.synchronize do
        @@allowed_ranges_last_updated = Time.now

        @@allowed_ranges =
          [10, 180, 0, 0, 16],
          [100, 66, 0, 0, 16],
          [100, 67, 0, 0, 16]
      end

      return @@allowed_ranges
    end

    def cidr_must_be_in_reserved_range
      cidr_array = cidr.split(".")
      given_cidr_range_found = false
      allowed_ranges.each do |range|
        # check the first two digits if the cidr choosen cidr is supported
        if (range[0].to_s == cidr_array[0].to_s) &&
             (range[1].to_s == cidr_array[1].to_s)
          puts "found cidr range"
          given_cidr_range_found = true
          # check validity of the given cidr
          # https://blog.markhatton.co.uk/2011/03/15/regular-expressions-for-ip-addresses-cidr-ranges-and-hostnames/
          unless cidr.match(
                   /^(#{range[0].to_s}\.#{range[1].to_s}\.([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5]))\.([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])(\/([0-9]|[1-2][0-9]|3[0-2]))$/,
                 )
            errors.add(
              :cidr,
              "must be within the #{range[0]}.#{range[1]}.0.0/16 range.",
            )
          end
        end
      end

      unless given_cidr_range_found
        errors.add(:cidr, "#{cidr} is not a valid cidr or range.")
      end
    end
  end
end

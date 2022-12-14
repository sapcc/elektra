# frozen_string_literal: true

module Compute
  # Represents Openstack Flavor
  class Flavor < Core::ServiceLayer::Model
    # avoid . and /
    validates :id, format: { with: %r{\A[^\./]*\z} }
    def to_s
      "#{name}, #{vcpus} VCPUs, #{disk}GB Disk, #{ram}MB Ram"
    end

    # FOG already maps this field to ephemeral. It is only a backup.
    def ephemeral
      read("OS-FLV-EXT-DATA:ephemeral") || read("ephemeral")
    end

    # convert is_public to boolean.
    def public?
      result = read("os-flavor-access:is_public") || read("is_public")
      result == "1" || result == true
    end

    # overwrite (defined in model.rb)
    # The save method is defined in the superclass.
    # This method is used for both create and for update.
    # However Flavors API does not support update. Therefore we override
    # save so that it simulates an update by deleting the old flavor first and
    # then creating a new one with the same id.
    def save
      # execute before callback
      before_save
      return false unless valid?

      rescue_api_errors do
        begin
          @service.delete_flavor(id) unless id.blank?
        rescue ::Elektron::Errors::ApiResponse => e
          # 404 while deleting is not an error
          raise e unless e.code == 404
        end
        # create the new flavor. Caution: if this operation fails then it is
        # just a delete.
        new_attributes = attributes_for_create
        new_attributes["id"] = id unless id.blank?

        self.attributes = @service.create_flavor(new_attributes)
        after_save
      end
    end

    # this method is called by save. It allows us to map values
    # passed to the API. For example the is_public attribute is
    # converted to string.
    def attributes_for_create
      {
        "name" => read("name"),
        "ram" => read("ram"),
        "vcpus" => read("vcpus"),
        "disk" => read("disk"),
        "rxtx_factor" => read("rxtx_factor"),
        "swap" => read("swap"),
        "OS-FLV-EXT-DATA:ephemeral" => ephemeral,
        "os-flavor-access:is_public" => public?,
      }.delete_if { |_k, v| v.nil? || (v.respond_to?(:empty?) && v.empty?) }
    end
  end
end

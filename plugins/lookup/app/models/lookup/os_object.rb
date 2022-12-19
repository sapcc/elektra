module Lookup
  class OsObject < Core::ServiceLayer::Model
    def attributes_for_create
      { "os_type" => read("os_type") }.delete_if { |_k, v| v.blank? }
    end
  end
end

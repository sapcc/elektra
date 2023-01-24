module Lbaas2
  class Healthmonitor < Core::ServiceLayer::Model
    validates :name, presence: true
    validates :type, presence: true
    validates :delay, presence: true, numericality: { greater_than: 0 }
    validates :max_retries_down,
              inclusion: {
                in: 1..10,
                message: "A valid value is from 1 to 10",
                allow_blank: true
              }

    # max_retries fix default to 1 https://github.com/sapcc/elektra/pull/1175
    # timeout fix default to 0 https://github.com/sapcc/elektra/pull/1176
    def attributes_for_create
      {
        "name" => read("name"),
        "type" => read("type"),
        "max_retries" => 1,
        "max_retries_down" => read("max_retries_down"),
        "timeout" => 0,
        "delay" => read("delay"),
        "http_method" => read("http_method"),
        "expected_codes" => read("expected_codes"),
        "url_path" => read("url_path"),
        "tags" => read("tags"),
        "pool_id" => read("pool_id"),
        "project_id" => read("project_id"),
      }.delete_if { |_k, v| v.blank? }
    end

    # http_method should be removed of the update object if "nil" and not empty string    
    # max_retries fix default to 1 https://github.com/sapcc/elektra/pull/1175
    # timeout fix default to 0 https://github.com/sapcc/elektra/pull/1176
    def attributes_for_update
      {
        "name" => read("name"),
        "max_retries" => 1,
        "max_retries_down" => read("max_retries_down"),
        "timeout" => 0,
        "delay" => read("delay"),
        "http_method" => read("http_method"),
        "expected_codes" => read("expected_codes"),
        "url_path" => read("url_path"),
        "tags" => read("tags"),
      }.delete_if { |_k, v| v.nil? }
    end
  end
end

module Identity
  class User < Core::ServiceLayer::Model
    validates :description, presence: true

    def full_name
      description.nil? || description.empty? ? name : description
    end

    def attributes_for_create
      {
        "name" => read("name"),
        "default_project_id" => read("default_project_id"),
        "domain_id" => read("domain_id"),
        "email" => read("email"),
        "enabled" => read("enabled"),
        "description" => read("description"),
        "password" => read("password"),
      }.delete_if { |_k, v| (v.nil? || (v.is_a?(String) && v.empty?)) }
    end

    def attributes_for_update
      attributes_for_create
    end
  end
end

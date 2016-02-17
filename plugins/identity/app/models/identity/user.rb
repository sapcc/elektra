module Identity
  class User < Core::ServiceLayer::Model
    def full_name
      (description.nil? or description.empty?) ? name : description
    end
  end
end
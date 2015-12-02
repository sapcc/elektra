module Identity
  class User < DomainModelServiceLayer::Model
    def full_name
      (description.nil? or description.empty?) ? name : description
    end
  end
end
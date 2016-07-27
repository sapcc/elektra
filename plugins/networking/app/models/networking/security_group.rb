module Networking
  class SecurityGroup < Core::ServiceLayer::Model
    validates :name, presence: true
  end
end

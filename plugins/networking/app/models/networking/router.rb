module Networking
  class Router < Core::ServiceLayer::Model
    validates :name, presence: { message: 'Please provide a name' }


  end
end

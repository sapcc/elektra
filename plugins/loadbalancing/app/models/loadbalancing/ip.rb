module Loadbalancing
  class Ip < Core::ServiceLayer::Model
    attr_accessor :selected, :ip, :name
  end
end

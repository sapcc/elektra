# frozen_string_literal: true

module Loadbalancing
  class Ip < Core::ServiceLayer::Model
    attr_accessor :selected, :ip, :name, :id
  end
end

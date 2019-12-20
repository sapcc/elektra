# frozen_string_literal: true

module Lbaas
  class Ip < Core::ServiceLayer::Model
    attr_accessor :selected, :ip, :name, :id
  end
end

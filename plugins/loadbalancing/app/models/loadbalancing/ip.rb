# frozen_string_literal: true

module Loadbalancing
  class Ip < Core::ServiceLayerNg::Model
    attr_accessor :selected, :ip, :name
  end
end

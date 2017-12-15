# frozen_string_literal: true

module BlockStorage
  class VolumeServer
    include ActiveModel::Validations
    include ActiveModel::Conversion
    extend ActiveModel::Naming

    attr_accessor :server, :volume
    attr_accessor :servers
    attr_accessor :device

    validates_presence_of :server

    def initialize(attributes = {})
      return if attributes.blank?
      attributes.each { |name, value| send("#{name}=", value) }
    end
  end
end

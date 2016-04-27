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
      attributes.each do |name, value|
        send("#{name}=", value)
      end unless attributes.blank?
    end

  end
end
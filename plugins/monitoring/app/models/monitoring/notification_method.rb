module Monitoring
  class NotificationMethod < Core::ServiceLayer::Model
    # The following properties are known
    # id
    # address
    # name
    # type
    #
    validates_presence_of :name, :address, :type
    # this is stolen from rails doc ;-)
    validates :address, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i }
    # https://github.com/openstack/monasca-api/blob/master/docs/monasca-api-spec.md#request-body-7
    validates :address, length: { maximum: 100 }
    validates :name, length: { maximum: 250 }
    validates :type, length: { maximum: 100 }

    def type
      if read(:type)
        return read(:type).upcase
      end
    end

    def supported_types
      ['Email']
    end
  end
end

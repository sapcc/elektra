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

  end
end

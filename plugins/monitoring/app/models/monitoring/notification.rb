module Monitoring
  class Notification < Core::ServiceLayer::Model
    # The following properties are known
    # id
    # address
    # name
    # type
    #
    validates_presence_of :name, :address, :type
  end
end

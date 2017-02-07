module Monitoring
  class NotificationMethod < Core::ServiceLayer::Model
    # The following properties are known
    # id
    # address
    # name
    # type
    #
    validates_presence_of :name, :address, :type
    
    # TODO: do I need address validation here? because the address can be everthing, from email to url
    # validates :address, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i }
    # https://github.com/openstack/monasca-api/blob/master/docs/monasca-api-spec.md#request-body-7
    # validates :address, length: { maximum: 100 }
    
    validates :name, length: { maximum: 250 }
    validates :type, length: { maximum: 100 }

    def supported_types
      [['Email','EMAIL'],['Slack','SLACK'],['Webhook','WEBHOOK']]
    end
  end
end

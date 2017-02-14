module Monitoring
  class NotificationMethod < Core::ServiceLayer::Model
    # The following properties are known
    # id
    # address
    # name
    # type

    validates_presence_of :name, :address, :type
    # EMAIL
    validates :address, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i }, if: Proc.new{|u| u.type == "EMAIL"}
    # SLACK and WEBHOOCK
    validates :address, format: { with: URI.regexp }, if: Proc.new{|u| u.type == "SLACK"} ||  Proc.new{|u| u.type == "WEBHOCK"}
    
    validates :address, length: { maximum: 100 }
    validates :name, length: { maximum: 250 }
    validates :type, length: { maximum: 100 }

    def supported_types
      [['Email','EMAIL'],['Slack','SLACK'],['Webhook','WEBHOOK']]
    end
  end
end

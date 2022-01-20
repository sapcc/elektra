module EmailService
  class Configset 
    include Virtus.model
    extend ActiveModel::Naming
    include ActiveModel::Conversion
    include ActiveModel::Validations
    include ActiveModel::Validations::Callbacks
    include ::EmailService::ConfigsetHelper

    attribute :name, String
    attribute :event_destinations, String

    strip_attributes

    # validation
    validates_presence_of :name

    def persisted?
      false
    end

    private


    def assign_errors(messages)
      messages.each do |key, value|
        value.each do |item|
          errors.add key.to_sym, item
        end
      end
    end

    # def initialize(opts = {})
    #   @name       = opts[:name]
    #   @event_destinations = opts[:event_destinations]
    #   @errors     = validate_opts(opts)
    # end 
  
    # def name
    #   @name
    # end

    # def errors?
    #   @errors.empty? ? false : true
    # end

    # def errors
    #   @errors
    # end

    # def validate_opts(opts)
    #   errors = []
    #   if opts[:name] == "" || opts[:name].nil?
    #     errors.push({ name: "name", message: "Configset name can't be empty" })
    #   end
    #   errors
    # end

  end
end
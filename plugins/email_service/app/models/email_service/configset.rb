module EmailService
  class Configset 
    include Virtus.model
    extend ActiveModel::Naming
    include ActiveModel::Conversion
    include ActiveModel::Validations
    include ActiveModel::Validations::Callbacks

    attribute :name, String
    attribute :event_destinations, String

    strip_attributes

    # validation
    validates_presence_of :name

    def to_model
      self
    end
    
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

  end
end
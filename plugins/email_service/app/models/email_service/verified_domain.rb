module EmailService
  class VerifiedDomain

    include Virtus.model
    extend ActiveModel::Naming
    include ActiveModel::Conversion
    include ActiveModel::Validations
    include ActiveModel::Validations::Callbacks
    include ::EmailService::Helpers

    attribute :identity, String
    attribute :dkim_enabled, Boolean
    strip_attributes

    # validation
    validates_presence_of :identity, message: "domain can't be empty"
    validates :identity, presence: true, domain: true


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
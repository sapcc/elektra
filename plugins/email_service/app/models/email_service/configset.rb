module EmailService
  class Configset
    include Virtus.model
    extend ActiveModel::Naming
    include ActiveModel::Conversion
    include ActiveModel::Validations
    include ActiveModel::Validations::Callbacks

    attribute :name, String
    attribute :event_destinations, String
    # added with v2 conversion
    attribute :tls_policy, String
    attribute :custom_redirect_domain, String
    attribute :sending_pool_name, String
    attribute :reputation_metrics_enabled, Boolean
    attribute :last_fresh_start, DateTime
    attribute :sending_enabled, Boolean
    attribute :tags, Array[String]
    attribute :suppressed_reasons, Array[String]

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

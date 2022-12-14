module EmailService
  class Forms::MulticloudAccount
    include Virtus.model
    extend ActiveModel::Naming
    include ActiveModel::Conversion
    include ActiveModel::Validations
    include ActiveModel::Validations::Callbacks
    include ::EmailService::Helpers

    attribute :account_env, String
    attribute :identity, String
    attribute :mail_type, String
    attribute :provider, String
    attribute :security_officer, String
    attribute :endpoint_url, String

    strip_attributes

    # validation
    validates_presence_of :account_env,
                          message: "Account environment can't be empty"
    validates_presence_of :identity, message: "Identity can't be empty"
    validates_presence_of :mail_type, message: "Mail type can't be empty (aws)"
    validates_presence_of :provider, message: "provider can't be empty"
    validates_presence_of :security_officer,
                          message:
                            "A valid sap email address or SAP User ID of Security Officer is needed."
    validates :identity, presence: true, email: true

    def to_model
      self
    end

    def persisted?
      false
    end

    def process(multicloud_account_instance)
      process!(multicloud_account_instance)
    end

    private

    def process!(multicloud_account_instance)
      multicloud_account = multicloud_account_instance.new
      begin
        multicloud_account.form_to_attributes(attributes)
      rescue StandardError => e
        errors.add "multicloud_account_attributes".to_sym, e.inspect
      end
      if !multicloud_account.errors.blank?
        messages =
          multicloud_account.errors.blank? ? {} : multicloud_account.errors
        assign_errors(messages)
      end
      multicloud_account
    end

    def assign_errors(messages)
      messages.each do |key, value|
        value.each { |item| errors.add key.to_sym, item }
      end
    end
  end
end

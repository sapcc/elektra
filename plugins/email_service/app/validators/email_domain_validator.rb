# frozen_string_literal: true

require 'active_model'
# Email and DomainValidator
class EmailDomainValidator < ActiveModel::EachValidator
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  VALID_DOMAIN_REGEX = /\b((?=[a-z0-9-]{1,63}\.)(xn--)?[a-z0-9]+(-[a-z0-9]+)*\.)+[a-z]{2,63}\b/i
  def validate_each(record, attribute, value)
    return if VALID_EMAIL_REGEX.match?(value) || VALID_DOMAIN_REGEX.match?(value)

    record.errors.add attribute,
                      (options[:message] || "identity: #{value} is invalid")
  end
end

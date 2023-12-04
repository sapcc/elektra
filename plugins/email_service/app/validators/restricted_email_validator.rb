# frozen_string_literal: true

require "mail"
require "active_model"
# ResctrictedEmailValidator
class RestrictedEmailValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i.match?(value)
      record.errors.add attribute,
                        (options[:message] || "[#{value}] - invalid email address.")
    end
    if value.include?("@sap.com")
      record.errors.add attribute,
                        (options[:message] || "[#{value}] - sending from sap.com email address is restricted. Please open a ticket and follow approval process to send email from this address.")
    else
      return 
    end
  end
end

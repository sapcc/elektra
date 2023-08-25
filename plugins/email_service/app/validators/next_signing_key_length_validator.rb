# frozen_string_literal: true

require 'active_model'

# NextSigningKeyLengthValidator
class NextSigningKeyLengthValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if (value.include?('RSA_1024_BIT') || value.include?('RSA_2048_BIT'))
    record.errors.add attribute,
                      (
                        options[:message] ||
                          'Invalid: expecting RSA_1024_BIT or RSA_2048_BIT'
                      )
  end
end

# frozen_string_literal: true

require 'active_model'

# DomainSigningPrivateKeyValidator
class DomainSigningPrivateKeyValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if %r{^[a-zA-Z0-9+/]+={0,2}$}i.match?(value)

    record.errors.add attribute,
                      (
                        options[:message] ||
                          "Signing private key: #{value} is invalid; expecting regex: '^[a-zA-Z0-9+\/]+={0,2}$' "
                      )
  end
end

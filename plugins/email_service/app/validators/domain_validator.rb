# frozen_string_literal: true

require 'active_model'
# DomainValidator
class DomainValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if /^[a-zA-Z0-9][a-zA-Z0-9-]{1,61}[a-zA-Z0-9](?:\.[a-zA-Z]{2,})+$/i.match?(
         value,
       )
      return
    end

    record.errors.add attribute,
                      (options[:message] || "domain name: #{value} is invalid")
  end
end

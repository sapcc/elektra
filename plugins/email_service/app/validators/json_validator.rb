# frozen_string_literal: true

require 'active_model'
require 'json'

# JsonValidator
class JsonValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless valid_json?(value)
      record.errors.add attribute, (options[:message] || 'JSON is invalid')
    end
    return unless value || value.nil? || value.empty? || value == '{}'

    record.errors.add attribute, (options[:message] || "JSON can't be empty")
  end

  def valid_json?(json)
    JSON.parse(json)
  rescue StandardError
    nil ? true : false
  end
end

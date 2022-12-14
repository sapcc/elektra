require "active_model"
require "json"

class JsonValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless valid_json?(value)
      record.errors.add attribute, (options[:message] || "JSON is invalid")
    end
    if !value || value.nil? || value.empty? || value == "{}"
      record.errors.add attribute, (options[:message] || "JSON can't be empty")
    end
  end

  def valid_json?(json)
    begin
      JSON.parse(json)
    rescue StandardError
      nil ? true : false
    end
  end
end

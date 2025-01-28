# frozen_string_literal: true

require 'active_model'

# UrlValidator
class UrlValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless %r{\A(?:(?:https?|ftp)://)(?:\S+(?::\S*)?@)?(?:(?:(?:[1-9]\d?|1\d\d|2[0-4]\d|25[0-5])(?:\.(?:\d{1,3})){3})|(?:(?:[a-zA-Z\u00a1-\uffff0-9]+-?)*[a-zA-Z\u00a1-\uffff0-9]+)(?:\.(?:[a-zA-Z\u00a1-\uffff0-9]+(?:-[a-zA-Z\u00a1-\uffff0-9]+)*))*(?:\.(?:[a-zA-Z\u00a1-\uffff]{2,})))(?::\d{2,5})?(?:/[^\s]*)?\z}i.match?(value)
      record.errors.add attribute,
                        (options[:message] || "url: #{value} is invalid")
    end
  end
end

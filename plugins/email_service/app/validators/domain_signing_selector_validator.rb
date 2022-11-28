require 'active_model'

class DomainSigningSelectorValidator < ActiveModel::EachValidator

  def validate_each(record, attribute, value)
    unless /^[a-zA-Z0-9][a-zA-Z0-9-]{1,61}[a-zA-Z0-9](?:\.[a-zA-Z]{2,})+$/i.match?(value)
      record.errors.add attribute, (options[:message] || "signing selector: #{value} is invalid; expecting regex: '^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9]))$' " )
    end
  end

end
require "active_model"

class NextSigningKeyLengthValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless (value.include?("RSA_1024_BIT") || value.include?("RSA_2048_BIT"))
      record.errors.add attribute,
                        (
                          options[:message] ||
                            "Next Signing Key Length: #{value} is invalid; expecting RSA_1024_BIT or RSA_2048_BIT"
                        )
    end
  end
end

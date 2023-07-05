# frozen_string_literal: true

require 'mail'
require 'active_model'

# EmailValidator
class EmailValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    @parse_errors, @addresses, @valid_addresses, @invalid_addresses =
      validate_email_array(value)
    unless @parse_errors.empty?
      @parse_error_message =
        'PARSE ERROR: Invalid email address found. Please fix'
      @parse_errors.each do |e|
        @parse_errors_items =
          @parse_errors_items ? "#{@parse_errors_items}, #{e}," : "#{e},"
      end
      @parse_error_message = "#{@parse_error_message}: #{@parse_errors_items}"
      record.errors.add attribute, (options[:message] || @parse_error_message)
    end
    if @invalid_addresses.count.positive?
      @invalid_error_message = 'INVALID:'
      @invalid_addresses.each do |a|
        @invalid_entries = " #{a[:name]} #{a[:address]}"
      end
      @invalid_error_message =
        "#{@invalid_error_message} [ #{@invalid_entries} ] invalid entries found."
      record.errors.add attribute, (options[:message] || @invalid_error_message)
    end
    return unless @valid_addresses.count > 50

    @exceeded_error_message = 'EXCEEDED LIMIT:'
    @exceeded_error_message =
      "#{@exceeded_error_message} Too many (#{@valid_addresses.count}) email addresses. AWS SES allows only in total of 50."
    record.errors.add attribute, (options[:message] || @exceeded_error_message)
  end

  def validate_email_array(raw_str)
    errors = []
    addresses = []
    valid_addresses = []
    invalid_addresses = []

    begin
      raw_addresses = Mail::AddressList.new(raw_str)
    rescue Mail::Field::IncompleteParseError => e
      errors << e.value
    end

    unless raw_addresses.nil? || !raw_addresses
      raw_addresses.addresses.each do |a|
        address = {}
        address[:address] = a.address
        address[:name] = a.display_name if a.display_name
        addresses.push(address)
      end
    end

    unless addresses.empty?
      addresses.each do |a|
        if /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i.match?(a[:address])
          valid_addresses.push(a)
        else
          invalid_addresses.push(a)
        end
      end
    end

    [errors, addresses, valid_addresses, invalid_addresses]
  end
end

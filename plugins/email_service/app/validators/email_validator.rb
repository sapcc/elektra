require 'mail'
require 'active_model'

class EmailValidator < ActiveModel::EachValidator

  def validate_each(record, attribute, value)
    @addresses, @valid_addresses, @invalid_addresses = validate_email_array(value)
    @error_message ="INVAID: "
    if @invalid_addresses.count > 0
      @invalid_addresses.each do | a |
        @error_message = "#{@error_message} #{a[:name]} #{a[:address]}"
      end
      @error_message = "[ #{@error_message} ] entries found."
      record.errors.add attribute, (options[:message] || @error_message )
    end
    if @valid_addresses.count > 50 
      @error_message = "#{@error_message} Too many (#{@valid_addresses.count}) email addresses. AWS SES allows only in total of 50 email recipients in To, Cc and Bcc fields all together. " 
      record.errors.add attribute, (options[:message] || @error_message )
    end
  end

  def validate_email_array(raw_str)
    # VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
    addresses = []
    valid_addresses = []
    invalid_addresses = []
    raw_addresses = Mail::AddressList.new(raw_str)
    raw_addresses.addresses.each do |a|
      address = {}
      address[:address] = a.address
      address[:name]    = a.display_name if a.display_name
      addresses.push(address)
    end
    addresses.each do | a |
      if /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i.match?(a[:address])
        valid_addresses.push(a) 
      else
        invalid_addresses.push(a)
      end
    end unless addresses.empty?
    return addresses, valid_addresses, invalid_addresses
  end
  
end

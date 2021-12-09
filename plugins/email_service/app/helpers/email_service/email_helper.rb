module EmailService
  module EmailHelper
    include AwsSesHelper
    include PlainEmailHelper
    include TemplatedEmailHelper

    def new_email(attributes = {})
      email = PlainEmail.new(attributes)
    end

    def new_templated_email(attributes = {})
      email = TemplatedEmail.new(attributes)
    end


    # create an array of valid email addresses
    def addr_validate(raw_addr)
      unless raw_addr.empty?
        values = raw_addr.split(",")
        addr = []
        values.each do |value|
          addr << value.strip
        end
        return addr
      end
      return []
    end

    def email_to_array(plain_email)
      plain_email.email.to_addr= addr_validate(plain_email.email.to_addr)
      plain_email.email.cc_addr= addr_validate(plain_email.email.cc_addr)
      plain_email.email.bcc_addr = addr_validate(plain_email.email.bcc_addr)
      plain_email
    end

  end
end



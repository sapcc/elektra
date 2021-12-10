module EmailService
  module PlainEmailHelper

    class PlainEmail
      VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
     
      def initialize(opts = {})
        @source    = opts[:source]
        @to_addr   = convert_valid_email_array(opts[:to_addr])
        @cc_addr   = convert_valid_email_array(opts[:cc_addr])
        @bcc_addr  = convert_valid_email_array(opts[:bcc_addr])
        @subject   = opts[:subject]
        @htmlbody  = opts[:htmlbody]
        @textbody  = opts[:textbody]
        @errors    = validate_opts(opts)
      end
      
      def source
        @source
      end

      def to_addr
        @to_addr
      end

      def cc_addr
        @cc_addr
      end

      def bcc_addr
        @bcc_addr
      end

      def subject
        @subject
      end

      def htmlbody
        @htmlbody
      end

      def textbody
        @textbody
      end

      def validate_opts(opts)
        errors = []
        if opts[:source] == "" || opts[:source].nil?
          errors.push({ name: "source", message: "Source can't be empty" })
        end
        if opts[:to_addr] == "" || opts[:to_addr].nil?
          errors.push({ name: "to_addr", message: "To Address can't be empty" })
        end
        if opts[:subject] == "" || opts[:subject].nil?
          errors.push({ name: "subject", message: "Subject can't be empty" })
        end
        if opts[:htmlbody] == "" || opts[:htmlbody].nil?
          errors.push({ name: "htmlbody", message: "Html body can't be empty" })
        end
        if opts[:textbody] == "" || opts[:textbody].nil?
          errors.push({ name: "textbody", message: "Text body can't be empty" })
        end
        errors
      end

      def errors
        @errors
      end
      
      def errors?
        @errors.empty? ? false : true
      end

      def empty_field?(obj)
        if obj.class == Array 
          obj.empty? || obj.size == 0  ? true : false
        else
          (obj.nil? || obj == " " || obj.length == 0) ? true : false
        end
      end

      def isvalid?
        @source && @to_addr && @subject && @htmlbody\
        && @textbody ? true : false
      end

      def convert_valid_email_array(str)
        addr_arr = []
        if str && !(str.nil? || str.blank?)
          email_addresses = str.split(",")
          email_addresses.each do | email_address |
            addr_arr << email_address.strip unless !is_valid_email?(email_address)
          end
        end
        addr_arr
      end

      def is_valid_email?(email)
        email.strip.match(VALID_EMAIL_REGEX).nil? ? false : true
      end

    end

  end
end

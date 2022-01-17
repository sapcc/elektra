module EmailService
  module TemplatedEmailHelper

    include TemplateHelper

    class TemplatedEmail
      VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  
      def initialize(opts = {})
        @source    = opts[:source]
        @to_addr   = convert_valid_email_array(opts[:to_addr])
        @cc_addr   = convert_valid_email_array(opts[:cc_addr])
        @bcc_addr  = convert_valid_email_array(opts[:bcc_addr])
        @reply_to_addr    = opts[:reply_to_addr]
        @template_name   = opts[:template_name]
        @template_data  = opts[:template_data]
        @configset_name  = opts[:configset_name]

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

      def reply_to_addr
        @reply_to_addr
      end

      def template_name
        @template_name
      end

      def template_data
        @template_data
      end

      def configset_name
        @configset_name
      end

      def validate_opts(opts)
        errors = []
        if opts[:source] == "" || opts[:source].nil?
          errors.push({ name: "source", message: "Source can't be empty" })
        end
        if opts[:to_addr] == "" || opts[:to_addr].nil?
          errors.push({ name: "to_addr", message: "To Address can't be empty" })
        end
        if opts[:template_name] == "" || opts[:template_name].nil?
          errors.push({ name: "template_name", message: "Template name can't be empty" })
        end
        if opts[:template_data] == "" || opts[:template_data].nil?
          errors.push({ name: "template_data", message: "Template Data body can't be empty" })
        end
        if opts[:reply_to_addr] == "" || opts[:reply_to_addr].nil?
          errors.push({ name: "reply_to_addr", message: "Reply-to Address  can't be empty" })
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
        @source && @to_addr && @template_name && @template_data\
        && @reply_to_addr ? true : false
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

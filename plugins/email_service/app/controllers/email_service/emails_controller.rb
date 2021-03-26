module EmailService
  class EmailsController < ::EmailService::ApplicationController
    include AwsSesHelper

    def index
      
    end

    def info
      @access, @secret = get_ec2_creds
      @ses_client = create_ses_client
      @verified_emails, @pending_emails = list_verified_emails
    end

    def show
    end

    def create
      @email = new_email(email_params)
      # plain_email = PlainEmail.new( {
      #   encoding: "UTF-8",
      #   source: "sirajudheenam@gmail.com",
      #   to_addr: [ "sirajudheenam@gmail.com", "sirajudheenam@gmail.com", "sirajudheenam@gmail.com" ],
      #   cc_addr: ["V4abc@xyz1.com", "V3abc@xyz2.com", "V2abc@xyz3.com", "V1abc@xyz4.com"],
      #   bcc_addr: ["P1abc@xyz1.com", "P2abc@xyz2.com", "P3abc@xyz3.com", "P4abc@xyz4.com"] ,
      #   subject: "Miracle Subject", 
      #   htmlbody: "<h1> HTML Body</h1>", 
      #   textbody: "Text Body",
      # })
      # @abc =  plain_email.email.inspect
      
      r_code = send_email(@email)

      if r_code
        redirect_to plugin('email_service').emails_path
      else
        render action: :new
      end
    end

    @email_addr_count = 0

    def addr_validate(addr)
      unless addr.empty?
        values = addr.split(",")
        addr = []
        values.each do |value|
          addr << value.strip
          @email_addr_count =  @email_addr_count + 1
        end
        return addr
      end
      return []
    end

    def email_params
      @ep = params['email']
      unless params['email'].blank?
        email = params.clone.fetch('email', {})
        # email.to_addr = addr_validate(params['email']['to_addr'])
        # email.cc_addr = addr_validate(params['email']['cc_addr'])
        # email.bcc_addr = addr_validate(params['email']['bcc_addr'])
        # if @email_addr_count > 50 
        #   puts "maximum number of email address including to, cc, bcc fields can't be more than 50"
        # end
        # remove if blank
        # email.delete_if { |key, value| value.blank? }
        return email
      end
      return {}
    end

  end
end

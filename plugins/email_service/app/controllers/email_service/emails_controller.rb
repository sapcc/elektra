module EmailService
  class EmailsController < ::EmailService::ApplicationController
    include AwsSesHelper
    include EmailHelper

    def index
      @verified_emails, @pending_emails = verified_emails

    end

    def info
      @access, @secret = get_ec2_creds
      @ses_client = create_ses_client
      @verified_emails, @pending_emails = list_verified_emails
    end

    def show
    end

    def new 
      @verified_emails, @pending_emails = verified_emails
      @e_collection = []
      @verified_emails.each do |e|
        @e_collection << e[:email]
        # logger.info "#{e[:email]} is included in to the collection"
      end
    end

    def create
      @verified_emails, @pending_emails = verified_emails
      @email = new_email(email_params)  
      # plain_email = PlainEmail.new( {
      #   encoding: "UTF-8",
      #   source: "sirajudheenam@gmail.com",
      #   to_addr: "sirajudheenam@gmail.com, sirajudheenam@gmail.com, sirajudheenam@gmail.com",
      #   cc_addr: "V4abc@xyz1.com, V3abc@xyz2.com, V2abc@xyz3.com, V1abc@xyz4.com",
      #   bcc_addr: "P1abc@xyz1.com, P2abc@xyz2.com, P3abc@xyz3.com, P4abc@xyz4.com",
      #   # to_addr: [ "sirajudheenam@gmail.com", "sirajudheenam@gmail.com", "sirajudheenam@gmail.com" ],
      #   # cc_addr: ["V4abc@xyz1.com", "V3abc@xyz2.com", "V2abc@xyz3.com", "V1abc@xyz4.com"],
      #   # bcc_addr: ["P1abc@xyz1.com", "P2abc@xyz2.com", "P3abc@xyz3.com", "P4abc@xyz4.com"] ,
      #   subject: "Miracle Subject", 
      #   htmlbody: "<h1> HTML Body</h1>", 
      #   textbody: "Text Body",
      # })
      # @plain_email_params =  plain_email.email.inspect
      @email1 = email_to_array(@email)
      logger.warn "@email1 : (inspect) " + @email1.inspect
      
      # Rails.logger.info "Check out this info! -- CRONUS" 
      # logger.debug "@email1 : (inspect) " + @email1.inspect

      success_from_controller = send_email(@email1)
      logger.warn "success from controller ??" + success_from_controller.to_s
      redirect_to plugin('email_service').emails_path
    end



    def email_params
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

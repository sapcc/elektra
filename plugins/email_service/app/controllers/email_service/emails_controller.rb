module EmailService
  class EmailsController < ::EmailService::ApplicationController
    include AwsSesHelper
    include EmailHelper

    def index

      @all_emails = list_verified_identities("EmailAddress")
      @verified_emails = get_verified_emails_by_status(@all_emails, "Success")
      @pending_emails  = get_verified_emails_by_status(@all_emails, "Pending")
      @failed_emails   = get_verified_emails_by_status(@all_emails, "Failed")
      @send_stats = get_send_stats
    end

    def stats
      @send_stats = get_send_stats # # JSON.pretty_generate(@send_stats.to_h)
    end

    def info

      @access, @secret = get_ec2_creds
      @ses_client = create_ses_client

      @all_emails = list_verified_identities("EmailAddress")
      @verified_emails = get_verified_emails_by_status(@all_emails, "Success")
      @pending_emails  = get_verified_emails_by_status(@all_emails, "Pending")
      @failed_emails   = get_verified_emails_by_status(@all_emails, "Failed")

      @send_stats = get_send_stats

      logger.debug "CRONUS: CONTROLLER : INSPECT #{@send_stats.inspect}"

    end

    def show
    end

    def new 

      @all_emails = list_verified_identities("EmailAddress")
      @verified_emails = get_verified_emails_by_status(@all_emails, "Success")
      @pending_emails  = get_verified_emails_by_status(@all_emails, "Pending")
      @failed_emails   = get_verified_emails_by_status(@all_emails, "Failed")

      @e_collection = get_verified_email_collection(@verified_emails) if !@verified_emails.empty?
      
    end


    def create
 
      # @verified_emails, @pending_emails = verified_emails
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


      result = email_to_array(@email)
      status = send_email(result)
      
      if status == "success"
        msg = "eMail sent successfully"
        flash[:success] = msg
      else 
        msg = "error occured: #{status}"
        flash[:warning] = msg
      end
      logger.debug "CRONUS DEBUG: #{msg}"
       
      redirect_to plugin('email_service').emails_path

    end

    def email_params
      unless params['email'].blank?
        email = params.clone.fetch('email', {})
        return email
      end
      return {}
    end


  end
end

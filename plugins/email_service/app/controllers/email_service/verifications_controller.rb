module EmailService
  class VerificationsController < ::EmailService::ApplicationController
    include AwsSesHelper

    def index
      @verified_emails, @pending_emails = verified_emails
      # @verified_emails = [ "V4abc@xyz1.com", "V3abc@xyz2.com", "V2abc@xyz3.com", "V1abc@xyz4.com" ]
      # @pending_emails = [ "P1abc@xyz1.com", "P2abc@xyz2.com", "P3abc@xyz3.com", "P4abc@xyz4.com" ]
      # @total_verified_emails = @verified_emails.count
      # @total_pending_emails = @pending_emails.count

    end

    def verify_email
      @recipient = params[:recipient].to_s
      verify_email(@recipient)
    end

    def new

    end
  end
end
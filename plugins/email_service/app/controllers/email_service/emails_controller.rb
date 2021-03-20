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

  end
end

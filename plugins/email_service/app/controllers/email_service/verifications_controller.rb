module EmailService
  class VerificationsController < ::EmailService::ApplicationController
    include AwsSesHelper

    def index
      @verified_emails, @pending_emails = verified_emails
    end

    def verify_email
      @recipient = params[:recipient].to_s
      verify_email(@recipient)
    end

    def new

    end
  end
end
# frozen_string_literal: true

module EmailService
  # EmailService EmailsController
  class EmailsController < ::EmailService::ApplicationController
    before_action :check_pre_conditions_for_cronus

    authorization_context 'email_service'
    authorization_required

    def index
      @nebula_details = nebula_details
      @nebula_status = nebula_status  
      @aws_account_details = aws_account_details
    end
  end
end

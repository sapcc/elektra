# frozen_string_literal: true

module ServiceLayer
  # This class implements the email_service api
  class EmailServiceService < Core::ServiceLayer::Service
    include EmailServiceServices::Email
    include EmailServiceServices::Template

    def available?(_action_name_sym = nil)
      elektron.service?('email-service')
    end

    def elektron_email_service
      @elektron_email_service ||= elektron.service(
        'email-aws', path_prefix: '/v1'
      )
    end

  end
end

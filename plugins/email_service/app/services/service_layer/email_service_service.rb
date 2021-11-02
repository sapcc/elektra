# frozen_string_literal: true

module ServiceLayer
  # This class implements the email_service api
  class EmailServiceService < Core::ServiceLayer::Service
    include EmailServiceServices::Email
    include EmailServiceServices::Template
    include EmailServiceServices::VerifiedEmail

    def available?(_action_name_sym = nil)
      elektron.service?('email-aws')
    end

    def elektron_email_service
      @elektron_email_service ||= elektron.service(
        'identity', path_prefix: '/v3'
      )
    end

    def elektron_identity_service
      @elektron_identity_service ||= elektron.service(
        'identity', path_prefix: '/v3'
      )
    end

  end
end

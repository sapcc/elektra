# frozen_string_literal: true

module ServiceLayer
  # This class implements the email_service api
  class EmailServiceService < Core::ServiceLayer::Service
    def available?(_action_name_sym = nil)
      elektron.service?('cronus')
    end

    def test
      elektron.service('email_service').get('/')
    end
  end
end

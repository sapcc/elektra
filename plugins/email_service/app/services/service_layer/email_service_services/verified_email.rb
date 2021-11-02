# frozen_String_literal: true

module ServiceLayer
  module EmailServiceServices
    # email api implementation
    module VerifiedEmail

      def verified_email_map
        @verified_email ||= class_map_proc(::EmailService::VerifiedEmail)
      end

      def new_verified_email(attributes = {})
        verified_email_map.call(attributes)
      end

    end
  end
end

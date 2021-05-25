# frozen_String_literal: true

module ServiceLayer
  module EmailServiceServices
    # email api implementation
    module Email

      Creds = Struct.new(:access, :secret)

      # def creds_map
      #   # @creds_map ||= class_map_proc(::EmailService::Email)
      #   @creds_map ||= class_map_proc(::EmailService::AWSCreds)
      # end

      # commented - 23 may 2021
      # def new_verified_email(attributes = {})
      #   creds_map.call(attributes)
      # end

      def aws_creds(user_id, filter = {})

        response = elektron_identity_service.get("users/#{user_id}/credentials/OS-EC2")
        creds_hash = response.body["credentials"].first
        aws_credentials = Creds.new(creds_hash["access"] , creds_hash["secret"])
        
      end

    end
  end
end

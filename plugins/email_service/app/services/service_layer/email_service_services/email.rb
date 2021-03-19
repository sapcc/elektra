# frozen_String_literal: true

module ServiceLayer
  module EmailServiceServices
    # email api implementation
    module Email

      def creds_map
        @creds_map ||= class_map_proc(::EmailService::Email)
      end

      def aws_creds(user_id, filter = {})
        # response = elektron_email_service.get("users/#{user_id}/credentials/OS-EC2")
        response = elektron_identity_service.get("users/#{user_id}/credentials/OS-EC2")
        {
          items: response.map_to('body.credentials', &creds_map),
          total: response.body['total']
        }
      end

      def get_aws_creds(user_id)
        ec2_creds = aws_creds(user_id, filter = {})
      end


    end
  end
end

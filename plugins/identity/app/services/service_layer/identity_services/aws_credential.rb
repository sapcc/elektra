# frozen_string_literal: true

module ServiceLayer
  module IdentityServices
    # This module implements Openstack User API
    module AWSCredential

      Creds = Struct.new(:access, :secret, :error)

      def aws_credential_map
        @paws_credential_map ||= class_map_proc(Identity::AWSCredential)
      end

      def aws_credentials(user_id, filter = {})
        response = elektron_identity.get("users/#{user_id}/credentials/OS-EC2")
        if !response.body["credentials"].empty?
          creds_hash = response.body["credentials"].first
          aws_credentials = Creds.new(creds_hash["access"] , creds_hash["secret"], "")
        else
          err = Creds.new("" , "", "AWS EC2 credentials are not created. Without this, email service will not work. Open your web-console and execute `openstack ec2 credentials create` command")
        end
      end

    end
  end
end

# frozen_string_literal: true

module ServiceLayer
  module IdentityServices
    # This module implements Openstack Credential API
    module Credential

      AWSCreds = Struct.new(:access, :secret, :error)

      def aws_credentials(user_id, project_id)
        aws_creds = [] 
        response = elektron_identity.get("users/#{user_id}/credentials/OS-EC2")
        if !response.body["credentials"].empty?
          creds_hash = response.body["credentials"]
          creds_hash.each do | creds |
            next if creds['tenant_id'] != project_id
            aws_creds << AWSCreds.new(creds["access"] , creds["secret"], "") 
          end
        else
          err = AWSCreds.new("" , "", "AWS EC2 credentials are not created. Without this, email service will not work. Open your web-console and execute `openstack ec2 credentials create` command")
        end
        err ? err : aws_creds.first
      end

      def all_ec2_creds(user_id, project_id)
        creds = []
        err = ""
        if user_id && project_id
          res = elektron_identity.get("users/#{user_id}/credentials/OS-EC2")
          if !res.body["credentials"].empty?
            creds_hash = response.body["credentials"]
            creds_hash.each do | creds |
              next if creds['tenant_id'] != project_id
              aws_creds << AWSCreds.new(creds["access"] , creds["secret"], "") 
          end
          else
            err = AWSCreds.new("" , "", "AWS EC2 credentials are not created. Without this, email service will not work. Open your web-console and execute `openstack ec2 credentials create` command")
          end
        else
          err = "user_id / project can't be empty"
        end
        [err, creds]
      end

      def get_project(project_id, user_id)
        res = elektron_identity.get("projects/#{project_id}/users/#{user_id}")
      end

      def get_user(user_id)
        res = elektron_identity.get("users/#{user_id}")
      end

    end
  end
end

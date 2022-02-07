# frozen_string_literal: true

module ServiceLayer
  module IdentityServices
    # This module implements Openstack Credential API
    module Ec2Credential

      def ec2_credential_map
        @ec2_credential_map ||= class_map_proc(Identity::Ec2Credential)
      end

      def new_ec2_credential(attributes = {})
        ec2_credential_map.call(attributes)
      end

      def find_ec2_credential!(user_id = nil, access_id = nil, options = {})
        return nil if access_id.blank? || user_id.blank?
        elektron_identity.get("users/#{user_id}/credentials/OS-EC2/#{access_id}", options).map_to(
          'body.credential', &ec2_credential_map
        )
      end

      def find_ec2_credential(user_id = nil, access_id = nil, options = {})
        find_ec2_credential!(user_id, access_id, options)
      rescue Elektron::Errors::ApiResponse
        nil
      end

      # find ec2 credentials of a user for a particular project if project_id given
      # else return all ec2 credentials of the user
      def ec2_credentials(user_id, filter = {})
        # caching
        @ec2_credentials ||= elektron_identity.get("users/#{user_id}/credentials/OS-EC2", filter).map_to(
          'body.credentials', &ec2_credential_map
        )
        return @ec2_credentials if filter[:tenant_id].nil?
        @ec2_credentials.select { |ec2_cred| ec2_cred.tenant_id == filter[:tenant_id] }
      end

      def project_ec2_credentials(user_id = nil, filter = {})
        @project_ec2_credentials = ec2_credentials(user_id, filter)
      end

      # find or create credentials for the current (project & user) context
      def find_or_create_ec2_credentials(user_id = nil, filter = {})
        return nil if user_id.blank?
        @created = false
        @fetched = project_ec2_credentials(user_id, filter)
        unless @fetched.empty?
          return @fetched.first
        else
          @created = new_ec2_credential({ user_id: user_id, project_id: filter[:tenant_id] }).save
          @creds = elektron_identity.get("users/#{user_id}/credentials/OS-EC2", filter).map_to(
                      'body.credentials', &ec2_credential_map
                    ) 
          return @creds.first if @created && @creds.length.positive?
        end
      end

      # Model methods

      def create_ec2_credential(params = {})
        return nil if params[:user_id].blank? || params[:project_id].blank?
        elektron_identity.post("users/#{params[:user_id]}/credentials/OS-EC2") do
          { tenant_id: params[:project_id] }
        end.body['credential']
      end

      def delete_ec2_credential(user_id = nil, access_id = nil)
        return nil if user_id.blank? || access_id.blank?
        elektron_identity.delete("users/#{user_id}/credentials/OS-EC2/#{access_id}")
      end

    end
  end
end

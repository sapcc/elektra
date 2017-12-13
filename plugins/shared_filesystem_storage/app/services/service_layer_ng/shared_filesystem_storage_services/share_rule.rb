# frozen_string_literal: true

module ServiceLayerNg
  module SharedFilesystemStorageServices
    # This module implements Openstack Designate Pool API
    module ShareRule
      def share_rules(share_id)
        elektron_service.post("shares/#{share_id}/action") do
          { access_list: nil }
        end.map_to('body.access_list') do |params|
          SharedFilesystemStorage::ShareRuleNg.new(self, params)
        end
      end

      def new_share_rule(params = {})
        SharedFilesystemStorage::ShareRuleNg.new(self, params)
      end

      ################# INTERFACE METHODS ######################
      def create_share_rule(share_id, params)
        elektron_service.post("shares/#{share_id}/action") do
          { allow_access: params }
        end.body
      end

      def delete_share(share_id, rule_id)
        elektron_service.post("shares/#{share_id}/action") do
          { deny_access: { access_id: rule_id } }
        end.body
      end
    end
  end
end

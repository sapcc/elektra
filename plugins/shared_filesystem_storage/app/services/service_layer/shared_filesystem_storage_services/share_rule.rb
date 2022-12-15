# frozen_string_literal: true

module ServiceLayer
  module SharedFilesystemStorageServices
    # This module implements Openstack Designate Pool API
    module ShareRule
      def share_rule_map
        @share_rule_map ||= class_map_proc(SharedFilesystemStorage::ShareRule)
      end

      def share_rules(share_id)
        elektron_shares
          .post("shares/#{share_id}/action") { { access_list: nil } }
          .map_to("body.access_list", &share_rule_map)
      end

      def new_share_rule(share_id, params = {})
        share_rule_map.call(params.merge(share_id: share_id))
      end

      ################# INTERFACE METHODS ######################
      def create_share_rule(share_id, params)
        elektron_shares
          .post("shares/#{share_id}/action") { { allow_access: params } }
          .body[
          "access"
        ]
      end

      def delete_share_rule(share_id, rule_id)
        elektron_shares.post("shares/#{share_id}/action") do
          { deny_access: { access_id: rule_id } }
        end
      end
    end
  end
end

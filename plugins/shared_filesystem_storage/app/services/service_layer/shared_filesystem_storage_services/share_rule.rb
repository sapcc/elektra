# frozen_string_literal: true

module ServiceLayer
  module SharedFilesystemStorageServices
    # This module implements Openstack Designate Pool API
    module ShareRule

      # need to use api version 2.44
      # 2.45 removes this access api via POST /action
      # and introduces GET /share-access-rules
      def elektron_share_access
        @elektron_share_access ||= elektron.service(
          'sharev2',
          headers: { 'X-OpenStack-Manila-API-Version' => "2.44" }
        )
      end

      def share_rule_map
        @share_rule_map ||= class_map_proc(SharedFilesystemStorage::ShareRule)
      end

      def share_rules(share_id)
        elektron_share_access.post("shares/#{share_id}/action") do
          { access_list: nil }
        end.map_to('body.access_list', &share_rule_map)
      end

      def new_share_rule(share_id, params = {})
        share_rule_map.call(params.merge(share_id: share_id))
      end

      ################# INTERFACE METHODS ######################
      def create_share_rule(share_id, params)
        elektron_share_access.post("shares/#{share_id}/action") do
          { allow_access: params }
        end.body['access']
      end

      def delete_share_rule(share_id, rule_id)
        elektron_share_access.post("shares/#{share_id}/action") do
          { deny_access: { access_id: rule_id } }
        end
      end
    end
  end
end

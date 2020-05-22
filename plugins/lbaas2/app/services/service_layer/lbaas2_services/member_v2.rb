module ServiceLayer
  module Lbaas2Services
    module MemberV2

      def member_map
        @member_map ||= class_map_proc(::Lbaas2::Member)
      end

      def members(id, filter = {})
        elektron_lb2.get("pools/#{id}/members", filter).map_to(
          'body.members', &member_map
        )
      end

      def new_member(attributes = {})
        member_map.call(attributes)
      end

      def create_member(pool_id, params)
        elektron_lb2.post("pools/#{pool_id}/members") do
          { member: params }
        end.body['member']
      end


    end
  end
end
# frozen_string_literal: true

module ServiceLayer
  module ImageServices
    module Member
      def member_map
        @member_map ||= class_map_proc(::Image::Member)
      end

      def add_member_to_image(image_id, project_id)
        response =
          elektron_images.post("images/#{image_id}/members") do
            { member: project_id }
          end
        response.map_to("body", &member_map)
      end

      def remove_member_from_image(image_id, member_id)
        elektron_images.delete("images/#{image_id}/members/#{member_id}")
      end

      def new_member(attributes = {})
        member_map.call(attributes)
      end

      def members(image_id)
        elektron_images.get("images/#{image_id}/members").map_to(
          "body.members",
          &member_map
        )
      end

      def accept_member(member)
        return false if member.nil?
        response =
          elektron_images.put(
            "images/#{member.image_id}/members/#{member.member_id}",
          ) { { status: "accepted" } }

        response.map_to("body", &member_map)
      end

      def reject_member(member)
        return false if member.nil?
        response =
          elektron_images.put(
            "images/#{member.image_id}/members/#{member.member_id}",
          ) { { status: "rejected" } }

        response.map_to("body", &member_map)
      end
    end
  end
end

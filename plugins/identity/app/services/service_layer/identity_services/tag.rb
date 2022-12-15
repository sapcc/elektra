# frozen_string_literal: true

module ServiceLayer
  module IdentityServices
    # This module implements Openstack Project Tags API without Rails Model
    module Tag
      # GET /v3/projects/{project_id}/tags
      def list_tags(project_id = nil)
        # no check for blank project_id, catch elektron or backend api error
        elektron_identity
          .get("projects/#{project_id}/tags")
          .body
          .fetch("tags", {})
      end

      # PUT /v3/projects/{project_id}/tags/{tag}
      def add_single_tag(project_id = nil, tag)
        # no check for blank project_id or tag, catch elektron or backend api error
        elektron_identity.put("projects/#{project_id}/tags/#{tag}")
      end

      # DELELTE /v3/projects/{project_id}/tags
      def remove_single_tag(project_id = nil, tag)
        # no check for blank project_id or tag, catch elektron or backend api error
        elektron_identity.delete("projects/#{project_id}/tags/#{tag}")
      end
    end
  end
end

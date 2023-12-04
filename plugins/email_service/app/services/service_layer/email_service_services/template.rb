# frozen_String_literal: true

module ServiceLayer
  module EmailServiceServices
    # nebula account api implementation
    module Template
      def template_map
        @template_map ||= class_map_proc(::EmailService::Template)
      end

      def new_template(attributes = {})
        template_map.call(attributes)
        # to use
        # services.email_service.new_template(attributes)
      end

      def find_template_by_name(name)
        return nil unless name
        elektron_email.get("templates/#{name}").map_to("body.template", &template_map)
      end

      def templates
        elektron_email.post("/", {
          Action: "ListTemplates",
          MaxItems: 1000,
        })
      end

      ################### Model Interface #############
      def create_template(attributes)
        elektron_email.post("templates") { { "template" => attributes } }.body[
          "template"
        ]
      end

      def update_template(id, attributes)
        elektron_email
          .put("templates/#{id}") { { "template" => attributes } }
          .body[
          "template"
        ]
      end

      def delete_template(name)
        elektron_email.delete("templates/#{name}")
      end
    end
  end
end

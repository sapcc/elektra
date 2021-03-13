# frozen_String_literal: true

module ServiceLayer
  module EmailServiceServices
    # template api implementation
    module Template
      def template_map
        @template_map ||= class_map_proc(::EmailService::Template)
      end

      def new_template(attributes = {})
        template_map.call(attributes)
      end

      def templates(filter = {})
        response = elektron_email_service.get('templates', filter)
        {
          items: response.map_to('body.templates', &template_map),
          total: response.body['total']
        }
      end

      def find_template!(uuid)
        elektron_email_service.get("templates/#{uuid}").map_to(
          'body', &template_map
        )
      end

      def find_template(uuid)
        find_template!(uuid)
      rescue Elektron::Errors::ApiResponse => _e
        nil
      end

      ################ MODEL INTERFACE ###################
      def create_template(attributes = {})
        template_ref = elektron_email_service.post('templates') do
          attributes
        end.body
        attributes.merge(template_ref)
      end

      def delete_template(id)
        elektron_email_service.delete("templates/#{id}")
      end
    end
  end
end

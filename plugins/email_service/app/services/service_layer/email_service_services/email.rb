# frozen_String_literal: true

module ServiceLayer
  module EmailServiceServices
    # email api implementation
    module Email
      def email_map
        @email_map ||= class_map_proc(::EmailService::Email)
      end

      def new_email(attributes = {})
        email_map.call(attributes)
      end

      def emails(filter = {})
        response = elektron_email_service.get('emails', filter)
        {
          items: response.map_to('body.emails', &email_map),
          total: response.body['total']
        }
      end

      def find_email!(uuid)
        elektron_email_service.get("emails/#{uuid}").map_to(
          'body', &email_map
        )
      end

      def find_email(uuid)
        find_email!(uuid)
      rescue Elektron::Errors::ApiResponse => _e
        nil
      end

      ################ MODEL INTERFACE ###################
      def create_email(attributes = {})
        email_ref = elektron_email_service.post('emails') do
          attributes
        end.body
        attributes.merge(email_ref)
      end

      def delete_email(id)
        elektron_email_service.delete("emails/#{id}")
      end
    end
  end
end

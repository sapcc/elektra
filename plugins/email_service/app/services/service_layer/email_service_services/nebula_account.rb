# frozen_String_literal: true

module ServiceLayer
  module EmailServiceServices
    # nebula account api implementation
    module NebulaAccount
      def nebula_account_map
        @nebula_account_map ||= class_map_proc(::EmailService::NebulaAccount)
      end

      def new_nebula_account(attributes = {})
        container_map.call(attributes)
      end

      def nebula_account(options = {})
        return nil if options == {}
        elektron_nebula.get("#{options[:provider]}/#{options[:project_id]}").map_to("body", &nebula_account_map)
      end

      ################### Model Interface #############
      def create_nebula_account(attributes)
        body =
          {
            accountEnv: attributes.account_env,
            identities: attributes.identity,
            mailType: attributes.mail_type || "TRANSACTIONAL",
            securityOfficer: attributes.security_officer,
          }
        elektron_nebula.post("#{attributes[:provider]}/#{attributes[:project_id]}", {}, body)
      end
    end
  end
end

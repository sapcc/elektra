# frozen_string_literal: true

module ServiceLayer
  module EmailServiceServices
    module NebulaAccount
      # WIP
      def get_nebula_account_details(auth_conf, options)
        @account_details ||= elektron_nebula_client(auth_conf, options)
      end
    end
  end
end

# frozen_string_literal: true

module Networking
  module Networks
    # External Networks
    class ExternalController < NetworksController
      private

      def load_type
        @network_type = 'external'
      end
    end
  end
end

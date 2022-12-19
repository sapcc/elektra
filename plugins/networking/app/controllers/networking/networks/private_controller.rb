# frozen_string_literal: true

module Networking
  module Networks
    # Private Networks
    class PrivateController < NetworksController
      private

      def load_type
        @network_type = "private"
      end
    end
  end
end

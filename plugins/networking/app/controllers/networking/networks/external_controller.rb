module Networking
  class Networks::ExternalController < NetworksController
    private

    def load_type
      @network_type = 'external'.freeze
    end
  end
end

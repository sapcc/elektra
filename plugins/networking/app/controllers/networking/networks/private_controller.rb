module Networking
  class Networks::PrivateController < NetworksController
    private

    def load_type
      @network_type = 'private'.freeze
    end
  end
end

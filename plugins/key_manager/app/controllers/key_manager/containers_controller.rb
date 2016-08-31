module KeyManager

  class ContainersController < ::Automation::ApplicationController

    def index
      @containers = []
      @secrets = services.key_manager.secrets()
    end

    def create
      binding.pry

      @containers = []
      @secrets = services.key_manager.secrets()
      render action: 'index'
    end

  end

end
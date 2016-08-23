module KeyManager

  class SecretsController < ::Automation::ApplicationController

    def index
      @secrets = services.key_manager.secrets()
    end

    def show
      @secret = services.key_manager.secret(params[:id])
    end

    def new
    end

    def create
    end

  end

end
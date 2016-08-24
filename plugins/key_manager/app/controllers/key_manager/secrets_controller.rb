module KeyManager

  class SecretsController < ::Automation::ApplicationController

    def index
      @secrets = services.key_manager.secrets()
    end

    def show
      @secret = services.key_manager.secret(params[:id])
    end

    def new
      @secret = ::KeyManager::Secret.new({})
    end

    def create
      @secret = services.key_manager.new_secret(secrets_params)

      # validate and check
      if @secret.valid? && @secret.save
        # flash[:success] = "Automation #{@automation.name} was successfully added."
        redirect_to plugin('key_manager').secrets_path
      else
        render action: "new"
      end
    end

    private

    def secrets_params
      unless params['secret'].blank?
        secret = params.clone.fetch('secret', {})
        secret.delete_if { |key, value| value.blank? }
        return secret
      end
      return {}
    end

  end

end
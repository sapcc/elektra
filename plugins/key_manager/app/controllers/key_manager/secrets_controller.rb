module KeyManager

  class SecretsController < ::Automation::ApplicationController
    before_action :secret_form_attr, only: [:new, :type_update, :create]

    def index
      @secrets = services.key_manager.secrets()
    end

    def show
      @secret = services.key_manager.secret(params[:id])
    end

    def new
      @secret = ::KeyManager::Secret.new({})
    end

    def type_update
      @secret = ::KeyManager::Secret.new({})
    end

    def create
      @secret = services.key_manager.new_secret(secrets_params)
      # validate and check
      if @secret.valid? && @secret.save
        # TODO should show a DISMISSIBLE flash message
        #flash[:success] = "Secret #{@secret.name} was successfully added."
        redirect_to plugin('key_manager').secrets_path
      else
        unless @secret.errors.messages[:global].blank?
          @secret.errors.messages[:global].each do |msg|
            if flash.now[:danger].nil?
              flash.now[:danger] = msg
            else
              flash.now[:danger] << " " + msg
            end
          end
        end
        render action: "new"
      end
    end

    def destroy
      @secret = services.key_manager.secret(params[:id])
      @secret.destroy
      flash.now[:success] = "Secret #{@secret.name} was successfully removed."
      @secrets = services.key_manager.secrets()
      render action: "index"
    end

    private

    def secret_form_attr
      @types = ::KeyManager::Secret::Type.to_hash
      @selected_type = params.fetch('secret', {}).fetch('secret_type', nil) || params[:secret_type] || ::KeyManager::Secret::Type::PASSPHRASE
      @payload_content_types = ::KeyManager::Secret::PayloadContentType.relation_to_type[@selected_type.to_sym]
      @payload_content_encoding = ::KeyManager::Secret::Encoding.relation_to_type[@selected_type.to_sym]
    end

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
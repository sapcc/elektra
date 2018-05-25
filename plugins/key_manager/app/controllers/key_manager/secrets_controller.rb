# frozen_string_literal: true

module KeyManager
  # secrets controller
  class SecretsController < ::KeyManager::ApplicationController
    before_action :secret_form_attr, only: %i[new type_update create]

    helper :all

    authorization_context 'key_manager'
    authorization_required except: %i[new type_update]

    def index
      @secrets = secrets
    end

    def show
      @secret = services.key_manager
                        .secret_with_metadata_payload(params[:id])
      unless @secret
        flash[:warning] = "Secret #{params[:id]} not found. Please check ACLs."
        redirect_to plugin('key_manager').secrets_path
      else
        # get the user name from the openstack id
        @user = service_user.identity.find_user(@secret.creator_id).try(:name)
      end
    end

    def new
      @secret = services.key_manager.new_secret
    end

    def type_update
      @secret = services.key_manager.new_secret
    end

    def payload
      @secret = services.key_manager.find_secret(params[:id])
      payload = services.key_manager.secret_payload(params[:id])
      send_data payload, filename: @secret.name
    end

    def create
      @secret = services.key_manager.new_secret(secrets_params)

      # validate and save
      if @secret.save
        flash[:success] = "Secret #{@secret.name} was successfully added."
        redirect_to plugin('key_manager').secrets_path
      else
        render action: 'new'
      end
    end

    def destroy
      # delete secret
      @secret = services.key_manager.new_secret
      @secret.id = params[:id]
      if @secret.destroy
        flash.now[:success] = "Secret #{params[:id]} was successfully removed."
      end
      # grap a new list of secrets
      @secrets = secrets
      # render
      render action: 'index'
    end

    private

    def secrets
      page = params[:page] || 1
      per_page = 10
      offset = (page.to_i - 1) * per_page
      result = services.key_manager.secrets(
        sort: 'created:desc', limit: per_page, offset: offset
      )
      Kaminari.paginate_array(
        result[:items], total_count: result[:total]
      ).page(page).per(per_page)
    end

    def secret_form_attr
      @types = ::KeyManager::Secret::Type.to_hash
      @selected_type = params.fetch('secret', {}).fetch('secret_type', nil) ||
                       params[:secret_type] ||
                       ::KeyManager::Secret::Type::PASSPHRASE

      @payload_content_types = ::KeyManager::Secret::PayloadContentType
                               .relation_to_type[@selected_type.to_sym]

      @selected_payload_content_type = secrets_params[:payload_content_type] ||
                                       @payload_content_types.find { |r| r == ::KeyManager::Secret::PayloadContentType::TEXTPLAIN } ||
                                       @payload_content_types.first

      @payload_encoding_relation = ::KeyManager::Secret::Encoding
                                   .relation_to_payload_content_type
    end

    def secrets_params
      return {} if params['secret'].blank?
      secret = params.clone.fetch('secret', {})

      # remove if blank
      secret.delete_if { |_key, value| value.blank? }

      # correct time
      unless secret.fetch(:expiration, nil).nil?
        date_time = DateTime.parse(secret['expiration'])
        secret[:expiration] = date_time.strftime('%FT%TZ')
      end

      secret
    end
  end
end

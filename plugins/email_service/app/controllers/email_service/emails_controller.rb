module EmailService
  class EmailsController < ::EmailService::ApplicationController
    include AwsSesHelper

    # before_action :email_form_attr, only: %i[new create]

    # helper :all

    # authorization_context 'key_manager'
    # authorization_required except: %i[]

    def index

    end

    def verify_email
      
    end

    def info
      @access, @secret = get_ec2_creds
      @ses_client = create_ses_client
      @verified_emails, @pending_emails = list_verified_emails
    end

    def show

    end

    # def new; end

    # def create
    #   @container = services.key_manager.new_container(container_params)
    #   if @container.save
    #     redirect_to plugin('key_manager').containers_path
    #   else
    #     render action: :new
    #   end
    # end

    # def destroy
    #   # delete container
    #   @container = services.key_manager.new_container
    #   @container.id = params[:id]

    #   if @container.destroy
    #     flash.now[:success] = "Container #{params[:id]} was successfully removed."
    #   end
    #   # grap a new list of secrets
    #   @containers = containers

    #   # render
    #   render action: :index
    # end

    # private

    # def containers
    #   page = params[:page] || 1
    #   per_page = params[:limit] || 10
    #   offset = (page.to_i - 1) * per_page
    #   result = services.key_manager.containers(
    #     sort: 'created:desc', limit: per_page, offset: offset
    #   )
    #   Kaminari.paginate_array(
    #     result[:items], total_count: result[:total]
    #   ).page(page).per(per_page)
    # end

    # def container_form_attr
    #   @types = ::KeyManager::Container::Type.to_hash
    #   @selected_type = params.fetch('container', {}).fetch('type', nil) ||
    #                    params[:container_type] ||
    #                    ::KeyManager::Container::Type::GENERIC
    #   @container = services.key_manager.new_container
    #   @selected_secrets = {}

    #   # get all secrets
    #   @secrets = []
    #   offset = 0
    #   limit = 100
    #   begin
    #     secrets_chunk = services.key_manager.secrets(
    #       sort: 'created:desc', offset: offset, limit: limit
    #     )
    #     @secrets += secrets_chunk[:items] unless secrets_chunk[:items].blank?
    #     offset += limit
    #   end while offset < secrets_chunk[:total].to_i

    #   # sort by type
    #   @symmetrics = []
    #   @public_keys = []
    #   @private_keys = []
    #   @passphrases = []
    #   @certificates = []
    #   @secrets.each do |element|
    #     case element.secret_type
    #       when Secret::Type::SYMMETRIC
    #         @symmetrics << element
    #       when Secret::Type::PUBLIC
    #         @public_keys << element
    #       when Secret::Type::PRIVATE
    #         @private_keys << element
    #       when Secret::Type::PASSPHRASE
    #         @passphrases << element
    #       when Secret::Type::CERTIFICATE
    #         @certificates << element
    #       else
    #     end
    #   end
    # end

    # def container_params
    #   unless params['container'].blank?
    #     container = params.clone.fetch('container', {})

    #     # remove if blank
    #     container.delete_if { |key, value| value.blank? }

    #     # add secrets
    #     case container['type']
    #       when Container::Type::CERTIFICATE
    #         secrets = container.fetch('secrets', {}).fetch(Container::Type::CERTIFICATE, {})
    #         unless secrets.blank?
    #           secrets.delete_if { |key, value| value.blank? }
    #           container['secret_refs'] = []
    #           secrets.each do |key, value|
    #             container['secret_refs'] << {name: key, secret_ref: value}
    #           end
    #         end
    #         @selected_secrets = secrets
    #       when Container::Type::RSA
    #         secrets = container.fetch('secrets', {}).fetch(Container::Type::RSA, {})
    #         unless secrets.blank?
    #           secrets.delete_if { |key, value| value.blank? }
    #           container['secret_refs'] = []
    #           secrets.each do |key,value|
    #             container['secret_refs'] << {name: key, secret_ref: value}
    #           end
    #         end
    #         @selected_secrets = secrets
    #       when Container::Type::GENERIC
    #         secrets = container.fetch('secrets', {}).fetch(Container::Type::GENERIC, {})
    #         unless secrets.blank?
    #           container['secret_refs'] = []
    #           secrets.each do |key, value|
    #             container['secret_refs'] << value
    #           end
    #         end
    #         @selected_secrets = secrets
    #     end

    #     return container
    #   end
    #   return {}
    # end
  end
end

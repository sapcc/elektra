module KeyManager

  class ContainersController < ::KeyManager::ApplicationController
    before_action :container_form_attr, only: [:new, :create]

    helper :all

    def index
      containers()
    end

    def new
      @types = ::KeyManager::Container::Type.to_hash
      @selected_type = ::KeyManager::Container::Type::GENERIC
      @secrets = services.key_manager.secrets({sort: 'created:desc', limit: 100})
      @container = ::KeyManager::Container.new({})
    end

    def create
      @container = services.key_manager.new_container(container_params)
      if @container.valid? && @container.save
        redirect_to plugin('key_manager').containers_path
      else
        fash_message_from_key([:secret_refs, :global], @container)
        render action: "new"
      end
    end

    def destroy
      # delete container
      @container = services.key_manager.container(params[:id])

      @container.destroy
      flash.now[:success] = "Container #{@container.name} was successfully removed."
      # grap a new list of secrets
      containers()

      # render
      render action: "index"
    end

    private

    def fash_message_from_key(keys, container)
      keys.each do |value|
        unless container.errors.messages[value].blank?
          container.errors.messages[value].each do |msg|
            if value == :secret_refs
              msg = "Secrets #{msg}"
            end
            if flash.now[:danger].nil?
              flash.now[:danger] = msg
            else
              flash.now[:danger] << " " + msg
            end
          end
        end
      end
    end

    def containers
      page = params[:page]||1
      per_page = 10
      offset = (page.to_i - 1) * per_page
      result = services.key_manager.containers({sort: 'created:desc', limit: per_page, offset: offset})
      @containers = Kaminari.paginate_array(result[:elements], total_count: result[:total_elements]).page(page).per(per_page)
    end

    def container_form_attr
      @types = ::KeyManager::Container::Type.to_hash
      @selected_type = ::KeyManager::Container::Type::GENERIC
      @secrets = services.key_manager.secrets({sort: 'created:desc', limit: 100})
      @container = ::KeyManager::Container.new({})
    end

    def container_params
      unless params['container'].blank?
        container = params.clone.fetch('container', {})

        # remove if blank
        container.delete_if { |key, value| value.blank? }

        # add secrets
        unless params.fetch('secrets', nil).nil?
          container['secret_refs'] = []
          params['secrets'].each do |key, value|
            secret_value = JSON.parse(value) rescue nil
            container['secret_refs'] << secret_value unless secret_value.nil?
          end
        end

        return container
      end
      return {}
    end

  end

end
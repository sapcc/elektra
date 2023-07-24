# frozen_string_literal: true

module EmailService
  # Configuration Set Controller
  class ConfigsetsController < ::EmailService::ApplicationController
    before_action :check_pre_conditions_for_cronus
    before_action :set_configset, only: %i[edit destroy update]

    authorization_context 'email_service'
    authorization_required

    def index
      items_per_page = 10
      @paginatable_configsets =
        Kaminari
          .paginate_array(configsets, total_count: configsets.count)
          .page(params[:page])
          .per(items_per_page)
    rescue Elektron::Errors::ApiResponse, StandardError => e
      error =
        "#{I18n.t('email_service.errors.configset_list_error')} #{e.message}"
      Rails.logger.error error
      flash[:error] = error
    end

    def create
      @configset = new_configset(configset_params)
      unless @configset.valid?
        render 'edit', local: { configset: @configset } and return
      end

      status = store_configset(@configset)
      if status == 'success'
        flash[:success] = "Configset #{@configset.name} is saved"
        redirect_to plugin('email_service').configsets_path and return
      else
        flash.now[:warning] = status
        render 'edit', local: { configset: @configset } and return
      end
    rescue Elektron::Errors::ApiResponse, StandardError => e
      error =
        "#{I18n.t('email_service.errors.configset_create_error')} #{e.message}"
      Rails.logger.error error
      flash[:error] = error
      redirect_to plugin('email_service').configsets_path
    end

    def show
      @id = params[:id] || nil
      @name = params[:name] || nil
      @configset_description = describe_configset(@name)
      render 'show', locals: { data: { modal: true } }
    rescue Elektron::Errors::ApiResponse, StandardError => e
      error =
        "#{I18n.t('email_service.errors.configset_show_error')} #{e.message}"
      Rails.logger.error error
      flash[:error] = error
    end

    def destroy
      name = params[:name] || nil
      status = delete_configset(@configset.name) if @configset

      flash[:success] = "Config Set: #{name} is removed" if status == 'success'
      flash[
        :error
      ] = "Config Set #{name} is not removed : #{status}" unless status ==
        'success'
      redirect_to plugin('email_service').configsets_path and return
    rescue Elektron::Errors::ApiResponse, StandardError => e
      error =
        "#{I18n.t('email_service.errors.configset_delete_error')} #{e.message}"
      Rails.logger.error error
      flash[:error] = error
    end

    def update
      status = store_configset(@configset)
      unless status.include?('success')
        render 'edit', locals: { data: { modal: true } } and return
      end
    rescue Elektron::Errors::ApiResponse, StandardError => e
      error =
        "#{I18n.t('email_service.errors.configset_update_error')} #{e.message}"
      Rails.logger.error error
      flash[:error] = error

      redirect_to plugin('email_service').configsets_path
    end

    private

    def set_configset
      @configset = find_configset(params[:name])
    end

    def configset_params
      if params.include?(:configset)
        params.require(:configset).permit(:name, :event_destinations)
      else
        {}
      end
    end
  end
end

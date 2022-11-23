module EmailService
  class ConfigsetsController < ::EmailService::ApplicationController

    before_action :check_ec2_creds_cronus_status
    before_action :check_verified_identity

    before_action :set_configset, only: %i[edit, destroy, update]

    authorization_context 'email_service'
    authorization_required

    def index

      items_per_page = 10
      @paginatable_configsets = Kaminari.paginate_array(configsets, total_count: configsets.count).page(params[:page]).per(items_per_page)
      rescue Elektron::Errors::ApiResponse => e
        error = "#{I18n.t('email_service.errors.configset_list_error')} #{e.message}"
        Rails.logger.error error
        flash[:error] = error
      rescue Exception => e
        error = "#{I18n.t('email_service.errors.configset_list_error')} #{e.message}"
        Rails.logger.error error
        flash[:error] = error
    end

    def new; end

    def create
      status = ""
      @configset = new_configset(configset_params)
      if !@configset.valid?
        render 'edit', local: {configset: @configset } and return
      else
        status = store_configset(@configset)
        if status == "success"
          flash[:success] = "Configset #{@configset.name} is saved"
          redirect_to plugin('email_service').configsets_path # and return
        else
          flash.now[:warning] = status
          render 'edit', local: {configset: @configset } and return
        end
      end
      rescue Elektron::Errors::ApiResponse => e
        error = "#{I18n.t('email_service.errors.configset_create_error')} #{e.message}"
        Rails.logger.error error
        flash[:error] = error
      rescue Exception => e
        error = "#{I18n.t('email_service.errors.configset_create_error')} #{e.message}"
        Rails.logger.error error
        flash[:error] = error
      redirect_to plugin('email_service').configsets_path
    end

    def show

      @id = params[:id] if params[:id]
      @name = params[:name] if params[:name]
      @configset_description = describe_configset(@name)
      render "show", locals: { data: { modal: true } }
      rescue Elektron::Errors::ApiResponse => e
        error = "#{I18n.t('email_service.errors.configset_show_error')} #{e.message}"
        Rails.logger.error error
        flash[:error] = error
      rescue Exception => e
        error = "#{I18n.t('email_service.errors.configset_show_error')} #{e.message}"
        Rails.logger.error error
        flash[:error] = error
    
    end

    def destroy

      status = ""
      name = params[:name] ?  params[:name] : ""
      configset = find_configset(params[:name])
      status = delete_configset(configset.name) if configset
      if status == "success"
        msg = "Config Set: #{name} is removed"
        flash[:success] = msg
      else
        msg = "Config Set #{name} is not removed : #{status}"
        flash[:error] = msg
      end
      redirect_to plugin('email_service').configsets_path and return
      rescue Elektron::Errors::ApiResponse => e
        error = "#{I18n.t('email_service.errors.configset_delete_error')} #{e.message}"
        Rails.logger.error error
        flash[:error] = error
      rescue Exception => e
        error = "#{I18n.t('email_service.errors.configset_delete_error')} #{e.message}"
        Rails.logger.error error
        flash[:error] = error

    end


    def edit
    end

    def update
      status = store_configset(@configset)
      unless status.include?("success")
        render "edit", locals: {data: {modal: true} } and return
      end
      rescue Elektron::Errors::ApiResponse => e
        error = "#{I18n.t('email_service.errors.configset_update_error')} #{e.message}"
        Rails.logger.error error
        flash[:error] = error
      rescue Exception => e
        error = "#{I18n.t('email_service.errors.configset_update_error')} #{e.message}"
        Rails.logger.error error
        flash[:error] = error
      redirect_to plugin('email_service').configsets_path
    end

    private

      def set_configset
        @configset = find_configset(params[:name])
      end

      def configset_params
        params.require(:configset).permit(:name, :event_destinations)
      end

  end
end

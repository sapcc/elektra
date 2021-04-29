module EmailService
  class SettingsController < ::EmailService::ApplicationController
    include AwsSesHelper
    include EmailHelper

    def index
      @cronus_activated = false
      access, secret = get_ec2_creds
      if access && secret 
        @cronus_activated = true
      end

      @configsets = get_configset

      # flash.now[:success] = "access key : #{access} secret : #{secret}" if (access && secret)
    end
    
    def enable_cronus
    end

    def disable_cronus
    end

    def new_configset

    end

    def create_configset
      # logger.debug "CRONUS: DEBUG: configset_params: #{params.inspect}"
      name = params[:configset][:name] if params[:configset][:name]
      status = configset_create(name)
      # logger.debug "CRONUS: DEBUG: create_configset (controller): #{status}"
      if status == "success"
        msg = "Config Set #{name} is saved"
        flash[:success] = msg
      else
        msg = "Config Set #{name} is not saved : #{status}"
        flash[:warning] = msg
      end
      redirect_to plugin('email_service').settings_path
    end

    def destroy_configset
      status = ""
      name = params[:name] ?  params[:name] : ""
      # logger.debug "CRONUS: DEBUG: params name #{name}"

      status = configset_destroy(name) if name

      if status == "success"
        msg = "Config Set #{name} is deleted"
        flash[:success] = msg
      else
        msg = "Config Set #{name} is not deleted : #{status}"
        flash[:warning] = msg
      end
     
      redirect_to plugin('email_service').settings_path

    end

  end
end
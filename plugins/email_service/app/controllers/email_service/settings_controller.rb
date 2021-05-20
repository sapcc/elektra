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
    def show_config
      @access, @secret = get_ec2_creds
    end

    def enable_cronus
    end

    def disable_cronus
    end

  end
end
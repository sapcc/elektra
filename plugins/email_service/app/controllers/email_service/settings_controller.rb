module EmailService
  class SettingsController < ::EmailService::ApplicationController
    include AwsSesHelper
    include EmailHelper

    def index
      @cronus_activated = false
      creds = get_ec2_creds
      @access = creds.access
      @secret = creds.secret

      if @access && @secret 
        @cronus_activated = true
      end

      @configsets = get_configset

    end
    def show_config
      creds = get_ec2_creds
      @access = creds.access
      @secret = creds.secret
    end

    def enable_cronus
    end

    def disable_cronus
    end

  end
end
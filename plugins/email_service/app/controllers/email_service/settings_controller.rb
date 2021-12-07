module EmailService
  class SettingsController < ::EmailService::ApplicationController
    before_action :restrict_access

    def index
      @cronus_activated = false
      creds = get_ec2_creds
      if creds.error.empty?
        @access = creds.access
        @secret = creds.secret
        if @access && @secret 
          @cronus_activated = true
        end
        @configsets = get_configset
      else
        flash[:error] = creds.error
      end
    rescue Elektron::Errors::ApiResponse => e
      flash[:error] = "Status Code: #{e.code} : Error: #{e.message}"
    rescue Exception => e
      flash[:error] = "Status Code: 500 : Error: #{e.message}"
    end

    def show_config
      creds = get_ec2_creds
      @access = creds.access
      @secret = creds.secret
    rescue Elektron::Errors::ApiResponse => e
      flash[:error] = "Status Code: #{e.code} : Error: #{e.message}"
    rescue Exception => e
      flash[:error] = "Status Code: 500 : Error: #{e.message}"
    end

    def enable_cronus
    end

    def disable_cronus
    end

  end
end

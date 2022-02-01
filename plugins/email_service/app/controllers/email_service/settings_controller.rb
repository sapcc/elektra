module EmailService
  class SettingsController < ::EmailService::ApplicationController
    before_action :restrict_access

    authorization_context 'email_service'
    authorization_required
    
    def index
      @cronus_activated = false
      if ec2_creds.error.nil?
        @access = ec2_creds.access
        @secret = ec2_creds.secret
        if @access && @secret 
          @cronus_activated = true
        end
      else
        flash[:error] = ec2_creds.error
      end
    rescue Elektron::Errors::ApiResponse => e
      flash[:error] = "Status Code: #{e.code} : Error: #{e.message}"
    rescue Exception => e
      flash[:error] = "Status Code: 500 : Error: #{e.message}"
    end

    def show
      @access = ec2_creds.access
      @secret = ec2_creds.secret
    rescue Elektron::Errors::ApiResponse => e
      flash[:error] = "Status Code: #{e.code} : Error: #{e.message}"
    rescue Exception => e
      flash[:error] = "Status Code: 500 : Error: #{e.message}"
    end

    # def enable
    #   flash[:info] = "Cronus is enabled"
    #   # Add code to enable
    #   redirect_to :index
    # end

    # def disable
    #   flash[:info] = "Cronus is disabled"
    #   # Add code to disable
    #   redirect_to :index
    # end

  end
end

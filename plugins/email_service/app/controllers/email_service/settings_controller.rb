module EmailService
  class SettingsController < ::EmailService::ApplicationController
    before_action :restrict_access

    authorization_context 'email_service'
    authorization_required
    
    def index
      @nebula_details = nebula_details
      @nebula_status = nebula_status
      puts @nebula_status
      puts @nebula_details
      @nebula_endpoint = "https://nebula.#{current_region}.cloud.sap"
      # debugger

      @cronus_active = false
      unless !ec2_creds && ec2_creds.nil?
        @access = ec2_creds.access
        @secret = ec2_creds.secret
        if @access && @secret 
          @cronus_active = true
        end
      else
        flash[:error] = "Cronus is not activated"
        check_user_creds_roles  
      end
    rescue Elektron::Errors::ApiResponse => e
      flash[:error] = "Status Code: #{e.code} : Error: #{e.message}"
    rescue Exception => e
      flash[:error] = "Status Code: 500 : Error: #{e.message}"
    end

  end
end

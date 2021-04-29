module EmailService
  class ApplicationController < DashboardController
    
    private

    def index
      redirect_to plugin('email_service').emails_path
    end
  end
end
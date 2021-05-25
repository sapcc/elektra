module EmailService
  class ApplicationController < DashboardController
    include AwsSesHelper
    include EmailHelper
    include TemplateHelper
    private

    def index
      redirect_to plugin('email_service').emails_path
    end
  end
end
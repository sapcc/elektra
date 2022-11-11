module EmailService
  class WebController < ::EmailService::ApplicationController
    # before_action :ui_switcher

    before_action :check_ec2_creds_cronus_status

    authorization_context 'email_service'
    authorization_required

    def index
    end

    def test
      @templates = templates
      @account = get_account
      @configsets = list_configsets(nil, 100)
      @contact_lists = list_contact_lists(nil, 1)
      items_per_page = 10
      @paginatable_templates  = Kaminari.paginate_array(@templates, total_count: @templates.count).page(params[:page]).per(items_per_page)
      rescue Elektron::Errors::ApiResponse => e
        flash[:error] = "Status Code: #{e.code} : Error: #{e.message}"
      rescue Exception => e
        flash[:error] = "Status Code: 500 : Error: #{e.message}"
    end

  end
end
